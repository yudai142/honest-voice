import React, { useState, useEffect } from 'react';

/**
 * RecurringScheduleForm - 定点観測スケジュール管理コンポーネント
 * Admin が定期実行スケジュールを作成・編集・一時停止・削除するための React コンポーネント
 */
const RecurringScheduleForm = ({ onScheduleChange }) => {
  const [schedules, setSchedules] = useState([]);
  const [questions, setQuestions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [showForm, setShowForm] = useState(false);
  const [editTarget, setEditTarget] = useState(null);
  const [submitting, setSubmitting] = useState(false);
  const [formErrors, setFormErrors] = useState([]);

  const defaultForm = {
    name: '',
    frequency: 'monthly',
    target_scope: 'all',
    question_template_id: '',
    next_scheduled_at: '',
  };

  const [formData, setFormData] = useState(defaultForm);

  const csrfToken = () =>
    document.querySelector('meta[name="csrf-token"]')?.content;

  useEffect(() => {
    fetchSchedules();
    fetchQuestions();
  }, []);

  const fetchSchedules = async () => {
    try {
      const res = await fetch('/admin/recurring_schedules.json');
      if (!res.ok) throw new Error('スケジュールの取得に失敗しました。');
      const json = await res.json();
      setSchedules(json.schedules || []);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  const fetchQuestions = async () => {
    try {
      const res = await fetch('/admin/questions.json');
      if (!res.ok) return;
      const json = await res.json();
      setQuestions(json.questions || []);
    } catch {
      // 質問テンプレート取得に失敗しても致命的ではない
    }
  };

  const openCreateForm = () => {
    setEditTarget(null);
    setFormData(defaultForm);
    setFormErrors([]);
    setShowForm(true);
  };

  const openEditForm = (schedule) => {
    setEditTarget(schedule);
    setFormData({
      name: schedule.name || '',
      frequency: schedule.frequency || 'monthly',
      target_scope: schedule.target_scope || 'all',
      question_template_id: schedule.question_template_id || '',
      next_scheduled_at: schedule.next_scheduled_at
        ? schedule.next_scheduled_at.slice(0, 16)
        : '',
    });
    setFormErrors([]);
    setShowForm(true);
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setFormErrors([]);

    const isEdit = !!editTarget;
    const url = isEdit
      ? `/admin/recurring_schedules/${editTarget.id}`
      : '/admin/recurring_schedules';
    const method = isEdit ? 'PATCH' : 'POST';

    try {
      const res = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken(),
        },
        body: JSON.stringify({ recurring_schedule: formData }),
      });

      const data = await res.json();

      if (!res.ok) {
        setFormErrors(data.errors || ['保存に失敗しました。']);
      } else {
        setShowForm(false);
        setEditTarget(null);
        await fetchSchedules();
        onScheduleChange?.();
      }
    } catch {
      setFormErrors(['通信エラーが発生しました。']);
    } finally {
      setSubmitting(false);
    }
  };

  const handlePause = async (schedule) => {
    try {
      await fetch(`/admin/recurring_schedules/${schedule.id}/pause`, {
        method: 'PATCH',
        headers: { 'X-CSRF-Token': csrfToken() },
      });
      await fetchSchedules();
    } catch {
      setError('一時停止に失敗しました。');
    }
  };

  const handleResume = async (schedule) => {
    try {
      await fetch(`/admin/recurring_schedules/${schedule.id}/resume`, {
        method: 'PATCH',
        headers: { 'X-CSRF-Token': csrfToken() },
      });
      await fetchSchedules();
    } catch {
      setError('再開に失敗しました。');
    }
  };

  const handleDelete = async (schedule) => {
    if (!confirm(`「${schedule.name}」を削除してよろしいですか？`)) return;

    try {
      await fetch(`/admin/recurring_schedules/${schedule.id}`, {
        method: 'DELETE',
        headers: { 'X-CSRF-Token': csrfToken() },
      });
      await fetchSchedules();
    } catch {
      setError('削除に失敗しました。');
    }
  };

  const frequencyLabel = (freq) => {
    const labels = { monthly: '毎月', quarterly: '四半期ごと', yearly: '毎年' };
    return labels[freq] || freq;
  };

  const statusBadge = (status) => {
    const config = {
      active: { cls: 'badge-success', label: '有効' },
      paused: { cls: 'badge-warning', label: '一時停止' },
      completed: { cls: 'badge-neutral', label: '完了' },
    };
    const { cls, label } = config[status] || { cls: 'badge-ghost', label: status };
    return <span className={`badge ${cls} badge-sm`}>{label}</span>;
  };

  if (loading) {
    return (
      <div className="flex justify-center p-10">
        <span className="loading loading-spinner loading-lg text-primary"></span>
      </div>
    );
  }

  return (
    <div>
      {error && (
        <div className="alert alert-error mb-4">
          <span>{error}</span>
          <button className="btn btn-ghost btn-xs" onClick={() => setError(null)}>✕</button>
        </div>
      )}

      {/* スケジュール一覧 */}
      {schedules.length === 0 ? (
        <div className="text-center py-12 text-base-content/50">
          <p className="text-lg mb-4">定点観測スケジュールがまだありません。</p>
          <button className="btn btn-primary" onClick={openCreateForm}>
            スケジュールを作成する
          </button>
        </div>
      ) : (
        <div>
          <div className="flex justify-end mb-4">
            <button className="btn btn-primary btn-sm" onClick={openCreateForm}>
              + 新規スケジュール
            </button>
          </div>
          <div className="overflow-x-auto">
            <table className="table table-zebra w-full">
              <thead>
                <tr>
                  <th>スケジュール名</th>
                  <th>頻度</th>
                  <th>対象</th>
                  <th>次回実行予定</th>
                  <th>前回実行</th>
                  <th>ステータス</th>
                  <th>操作</th>
                </tr>
              </thead>
              <tbody>
                {schedules.map((schedule) => (
                  <tr key={schedule.id}>
                    <td className="font-medium">{schedule.name}</td>
                    <td>{frequencyLabel(schedule.frequency)}</td>
                    <td>{schedule.target_scope === 'all' ? '全員' : '部署'}</td>
                    <td>
                      {schedule.next_scheduled_at
                        ? new Date(schedule.next_scheduled_at).toLocaleString('ja-JP', {
                            year: 'numeric', month: 'numeric', day: 'numeric',
                          })
                        : '—'}
                    </td>
                    <td>
                      {schedule.last_run_at
                        ? new Date(schedule.last_run_at).toLocaleString('ja-JP', {
                            year: 'numeric', month: 'numeric', day: 'numeric',
                          })
                        : '—'}
                    </td>
                    <td>{statusBadge(schedule.status)}</td>
                    <td>
                      <div className="flex gap-1 flex-wrap">
                        <button
                          className="btn btn-ghost btn-xs"
                          onClick={() => openEditForm(schedule)}
                        >
                          編集
                        </button>
                        {schedule.status === 'active' && (
                          <button
                            className="btn btn-warning btn-xs"
                            onClick={() => handlePause(schedule)}
                          >
                            停止
                          </button>
                        )}
                        {schedule.status === 'paused' && (
                          <button
                            className="btn btn-success btn-xs"
                            onClick={() => handleResume(schedule)}
                          >
                            再開
                          </button>
                        )}
                        <button
                          className="btn btn-error btn-xs"
                          onClick={() => handleDelete(schedule)}
                        >
                          削除
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* 作成・編集モーダル */}
      {showForm && (
        <div className="modal modal-open">
          <div className="modal-box max-w-lg">
            <h3 className="font-bold text-lg mb-4">
              {editTarget ? 'スケジュールを編集' : '新規スケジュール作成'}
            </h3>

            {formErrors.length > 0 && (
              <div className="alert alert-error mb-4">
                <ul className="list-disc list-inside">
                  {formErrors.map((err, i) => (
                    <li key={i}>{err}</li>
                  ))}
                </ul>
              </div>
            )}

            <form onSubmit={handleSubmit} className="space-y-4">
              {/* スケジュール名 */}
              <div className="form-control">
                <label className="label" htmlFor="schedule-name">
                  <span className="label-text">スケジュール名 <span className="text-error">*</span></span>
                </label>
                <input
                  id="schedule-name"
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  className="input input-bordered w-full"
                  placeholder="例: 月次チームフィードバック"
                  required
                />
              </div>

              {/* 頻度 */}
              <div className="form-control">
                <label className="label" htmlFor="schedule-frequency">
                  <span className="label-text">頻度 <span className="text-error">*</span></span>
                </label>
                <select
                  id="schedule-frequency"
                  name="frequency"
                  value={formData.frequency}
                  onChange={handleChange}
                  className="select select-bordered w-full"
                >
                  <option value="monthly">毎月</option>
                  <option value="quarterly">四半期ごと</option>
                  <option value="yearly">毎年</option>
                </select>
              </div>

              {/* 対象範囲 */}
              <div className="form-control">
                <label className="label" htmlFor="schedule-target">
                  <span className="label-text">対象範囲 <span className="text-error">*</span></span>
                </label>
                <select
                  id="schedule-target"
                  name="target_scope"
                  value={formData.target_scope}
                  onChange={handleChange}
                  className="select select-bordered w-full"
                >
                  <option value="all">全員</option>
                  <option value="department">部署</option>
                </select>
              </div>

              {/* 質問テンプレート */}
              <div className="form-control">
                <label className="label" htmlFor="schedule-template">
                  <span className="label-text">質問テンプレート</span>
                  <span className="label-text-alt text-base-content/50">任意</span>
                </label>
                <select
                  id="schedule-template"
                  name="question_template_id"
                  value={formData.question_template_id}
                  onChange={handleChange}
                  className="select select-bordered w-full"
                >
                  <option value="">— 選択してください —</option>
                  {questions.map((q) => (
                    <option key={q.id} value={q.id}>{q.title}</option>
                  ))}
                </select>
              </div>

              {/* 次回実行予定日時 */}
              <div className="form-control">
                <label className="label" htmlFor="schedule-next-run">
                  <span className="label-text">次回実行予定日時</span>
                  <span className="label-text-alt text-base-content/50">任意</span>
                </label>
                <input
                  id="schedule-next-run"
                  type="datetime-local"
                  name="next_scheduled_at"
                  value={formData.next_scheduled_at}
                  onChange={handleChange}
                  className="input input-bordered w-full"
                />
              </div>

              <div className="modal-action pt-2">
                <button
                  type="button"
                  className="btn btn-ghost"
                  onClick={() => setShowForm(false)}
                >
                  キャンセル
                </button>
                <button
                  type="submit"
                  className="btn btn-primary"
                  disabled={submitting}
                >
                  {submitting ? (
                    <span className="loading loading-spinner loading-sm"></span>
                  ) : (
                    editTarget ? '更新する' : '作成する'
                  )}
                </button>
              </div>
            </form>
          </div>
          <div className="modal-backdrop" onClick={() => setShowForm(false)}></div>
        </div>
      )}
    </div>
  );
};

export default RecurringScheduleForm;
