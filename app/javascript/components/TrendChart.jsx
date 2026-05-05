import React, { useState, useEffect, useRef } from 'react';

/**
 * TrendChart - 定点観測トレンドチャートコンポーネント
 * 複数回の定期調査の回答数・参加率の推移を Chart.js で可視化する
 */
const TrendChart = ({ questionId, title }) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const lineChartRef = useRef(null);
  const lineChartInstance = useRef(null);

  useEffect(() => {
    if (questionId) {
      fetchTrendData();
    } else {
      setLoading(false);
    }

    return () => {
      lineChartInstance.current?.destroy();
    };
  }, [questionId]);

  useEffect(() => {
    if (!data || !lineChartRef.current) return;
    renderChart();

    return () => {
      lineChartInstance.current?.destroy();
    };
  }, [data]);

  const fetchTrendData = async () => {
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

  const renderChart = () => {
    if (!window.Chart) return;

    const { trend_data: trendData } = data || {};
    if (!trendData || !trendData.length) return;

    lineChartInstance.current?.destroy();

    lineChartInstance.current = new window.Chart(lineChartRef.current, {
      type: 'line',
      data: {
        labels: trendData.map((d) => d.label),
        datasets: [
          {
            label: '回答数',
            data: trendData.map((d) => d.answer_count),
            borderColor: 'rgb(99, 102, 241)',
            backgroundColor: 'rgba(99, 102, 241, 0.1)',
            borderWidth: 2,
            tension: 0.3,
            fill: true,
            pointRadius: 4,
            pointHoverRadius: 6,
          },
        ],
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            position: 'top',
          },
          tooltip: {
            callbacks: {
              label: (ctx) => `回答数: ${ctx.parsed.y}件`,
            },
          },
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 1,
              precision: 0,
            },
          },
        },
      },
    });
  };

  if (!questionId) {
    return (
      <div className="flex flex-col items-center justify-center py-10 text-base-content/50">
        <svg xmlns="http://www.w3.org/2000/svg" className="h-12 w-12 mb-3" fill="none" viewBox="0 0 24 24" stroke="currentColor">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
        </svg>
        <p>質問を選択するとトレンドを表示します</p>
      </div>
    );
  }

  if (loading) {
    return (
      <div className="flex justify-center py-10">
        <span className="loading loading-spinner loading-md text-primary"></span>
      </div>
    );
  }

  if (error) {
    return (
      <div className="alert alert-warning">
        <span>{error}</span>
      </div>
    );
  }

  const hasTrend = data?.trend_data?.length > 0;

  return (
    <div className="card bg-base-100 shadow">
      <div className="card-body">
        <h3 className="card-title text-base">
          {title || '回答数の推移'}
        </h3>

        {hasTrend ? (
          <div className="relative" style={{ height: '240px' }}>
            <canvas ref={lineChartRef}></canvas>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center py-8 text-base-content/50">
            <p className="text-sm">トレンドデータがまだありません。</p>
            <p className="text-xs mt-1">定点観測が実行されると推移グラフが表示されます。</p>
          </div>
        )}

        {data?.question && (
          <div className="mt-2 text-xs text-base-content/60 flex gap-4">
            <span>総回答数: {data.total_count || 0}件</span>
            {data.question.deadline && (
              <span>締切: {new Date(data.question.deadline).toLocaleDateString('ja-JP')}</span>
            )}
          </div>
        )}
      </div>
    </div>
  );
};

export default TrendChart;
