import React, { useState, useEffect, useRef } from 'react';

/**
 * StatsDashboard - 統計ダッシュボードコンポーネント
 * 質問の回答統計を Chart.js で可視化する
 * - 選択肢/評価型: 棒グラフ + 円グラフ
 * - テキスト型: 自由記述一覧
 */
const StatsDashboard = ({ questionId }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const barChartRef = useRef(null);
  const pieChartRef = useRef(null);
  const barChartInstance = useRef(null);
  const pieChartInstance = useRef(null);

  useEffect(() => {
    fetchStats();
  }, [questionId]);

  useEffect(() => {
    if (!data) return;
    if (data.question.question_type === 'choice' || data.question.question_type === 'rating') {
      renderCharts();
    }
    return () => {
      barChartInstance.current?.destroy();
      pieChartInstance.current?.destroy();
    };
  }, [data]);

  const fetchStats = async () => {
    try {
      const res = await fetch(`/admin/questions/${questionId}/statistics.json`);
      if (!res.ok) throw new Error('データの取得に失敗しました。');
      const json = await res.json();
      setData(json);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const renderCharts = () => {
    if (!window.Chart) return;

    const { charts, choice_stats: choiceStats } = data;
    if (!charts || !choiceStats?.length) return;

    // 棒グラフ
    if (barChartRef.current) {
      barChartInstance.current?.destroy();
      barChartInstance.current = new window.Chart(barChartRef.current, {
        type: 'bar',
        data: {
          labels: choiceStats.map((c) => c.label),
          datasets: [
            {
              label: '回答数',
              data: choiceStats.map((c) => c.count),
              backgroundColor: charts.colors || '#3B82F6',
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: { legend: { display: false } },
          scales: { y: { beginAtZero: true, ticks: { stepSize: 1 } } },
        },
      });
    }

    // 円グラフ
    if (pieChartRef.current) {
      pieChartInstance.current?.destroy();
      pieChartInstance.current = new window.Chart(pieChartRef.current, {
        type: 'pie',
        data: {
          labels: choiceStats.map((c) => c.label),
          datasets: [
            {
              data: choiceStats.map((c) => c.rate),
              backgroundColor: charts.colors || [],
            },
          ],
        },
        options: {
          responsive: true,
          maintainAspectRatio: false,
          plugins: {
            tooltip: {
              callbacks: {
                label: (ctx) => `${ctx.label}: ${ctx.parsed.toFixed(1)}%`,
              },
            },
          },
        },
      });
    }
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center py-16">
        <span className="loading loading-spinner loading-lg" />
      </div>
    );
  }

  if (error) {
    return (
      <div className="alert alert-error">
        <span>{error}</span>
      </div>
    );
  }

  const { question, stats, answers, choice_stats: choiceStats } = data;
  const isChoiceOrRating = question.question_type === 'choice' || question.question_type === 'rating';

  return (
    <div className="space-y-6">
      {/* 統計サマリー */}
      <div className="stats stats-horizontal shadow w-full">
        <div className="stat">
          <div className="stat-title">総回答数</div>
          <div className="stat-value text-primary">{stats.total_answers}</div>
        </div>
        <div className="stat">
          <div className="stat-title">回答率</div>
          <div className="stat-value text-secondary">{stats.answer_rate}%</div>
        </div>
        {question.question_type === 'rating' && stats.average_rating != null && (
          <div className="stat">
            <div className="stat-title">平均評価</div>
            <div className="stat-value text-accent">{stats.average_rating}</div>
            <div className="stat-desc">/ 5.0</div>
          </div>
        )}
      </div>

      {/* 選択肢/評価型: グラフ */}
      {isChoiceOrRating && choiceStats?.length > 0 && (
        <>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            <div className="card bg-base-100 shadow">
              <div className="card-body">
                <h3 className="card-title text-base">回答分布（棒グラフ）</h3>
                <div style={{ height: 280, position: 'relative' }}>
                  <canvas ref={barChartRef} />
                </div>
              </div>
            </div>
            <div className="card bg-base-100 shadow">
              <div className="card-body">
                <h3 className="card-title text-base">回答比率（円グラフ）</h3>
                <div style={{ height: 280, position: 'relative' }}>
                  <canvas ref={pieChartRef} />
                </div>
              </div>
            </div>
          </div>

          {/* 選択肢別統計テーブル */}
          <div className="card bg-base-100 shadow">
            <div className="card-body">
              <h3 className="card-title text-base mb-4">選択肢別統計</h3>
              <div className="overflow-x-auto">
                <table className="table table-zebra w-full">
                  <thead>
                    <tr>
                      <th>選択肢</th>
                      <th className="text-right">回答数</th>
                      <th className="text-right">回答率</th>
                    </tr>
                  </thead>
                  <tbody>
                    {choiceStats.map((choice) => (
                      <tr key={choice.id}>
                        <td>{choice.label}</td>
                        <td className="text-right">{choice.count}</td>
                        <td className="text-right">{choice.rate}%</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </>
      )}

      {/* テキスト型: 自由記述一覧 */}
      {question.question_type === 'text' && (
        <div className="card bg-base-100 shadow">
          <div className="card-body">
            <h3 className="card-title text-base mb-4">
              自由記述回答一覧
              <span className="badge badge-ghost ml-2">{answers?.length || 0}件</span>
            </h3>
            {answers?.length > 0 ? (
              <div className="space-y-3">
                {answers.map((answer) => (
                  <div key={answer.id} className="bg-base-200 rounded-lg p-4 border border-base-300">
                    <p className="text-sm whitespace-pre-wrap">{answer.body}</p>
                    <p className="text-xs text-base-content/40 mt-2">
                      {new Date(answer.created_at).toLocaleString('ja-JP')}
                    </p>
                  </div>
                ))}
              </div>
            ) : (
              <p className="text-base-content/50 text-sm">回答はまだありません。</p>
            )}
          </div>
        </div>
      )}
    </div>
  );
};

export default StatsDashboard;
