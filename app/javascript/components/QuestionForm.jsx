import React, { useState } from 'react';

/**
 * QuestionForm - 質問作成・編集フォームコンポーネント
 * Admin が質問を作成/編集するための React フォーム
 */
const QuestionForm = ({ question = null, companyId, onSuccess, onCancel }) => {
  const isEdit = !!question;

  const [formData, setFormData] = useState({
    title: question?.title || '',
    body: question?.body || '',
    question_type: question?.question_type || 'text',
    status: question?.status || 'draft',
    choices: question?.choices || [],
  });

  const [errors, setErrors] = useState([]);
  const [submitting, setSubmitting] = useState(false);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData((prev) => ({ ...prev, [name]: value }));
  };

  const handleChoiceChange = (index, value) => {
    const updated = [...formData.choices];
    updated[index] = { ...updated[index], label: value };
    setFormData((prev) => ({ ...prev, choices: updated }));
  };

  const addChoice = () => {
    setFormData((prev) => ({
      ...prev,
      choices: [...prev.choices, { label: '' }],
    }));
  };

  const removeChoice = (index) => {
    const updated = formData.choices.filter((_, i) => i !== index);
    setFormData((prev) => ({ ...prev, choices: updated }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setErrors([]);

    const url = isEdit
      ? `/admin/questions/${question.id}`
      : '/admin/questions';
    const method = isEdit ? 'PATCH' : 'POST';

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    try {
      const res = await fetch(url, {
        method,
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify({
          question: {
            ...formData,
            company_id: companyId,
            choices_attributes: formData.choices.map((c) => ({
              id: c.id,
              label: c.label,
              _destroy: c._destroy,
            })),
          },
        }),
      });

      const data = await res.json();

      if (!res.ok) {
        setErrors(data.errors || ['保存に失敗しました。']);
      } else {
        onSuccess?.(data.question);
      }
    } catch {
      setErrors(['通信エラーが発生しました。']);
    } finally {
      setSubmitting(false);
    }
  };

  const needsChoices = formData.question_type === 'choice' || formData.question_type === 'rating';

  return (
    <div className="card bg-base-100 shadow-lg">
      <div className="card-body">
        <h2 className="card-title text-xl mb-4">
          {isEdit ? '質問を編集' : '新しい質問を作成'}
        </h2>

        {errors.length > 0 && (
          <div className="alert alert-error mb-4">
            <ul className="list-disc list-inside">
              {errors.map((err, i) => (
                <li key={i}>{err}</li>
              ))}
            </ul>
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-4">
          {/* タイトル */}
          <div className="form-control">
            <label className="label">
              <span className="label-text font-semibold">タイトル <span className="text-error">*</span></span>
            </label>
            <input
              type="text"
              name="title"
              value={formData.title}
              onChange={handleChange}
              placeholder="質問のタイトルを入力"
              className="input input-bordered w-full"
              required
            />
          </div>

          {/* 本文 */}
          <div className="form-control">
            <label className="label">
              <span className="label-text font-semibold">本文 <span className="text-error">*</span></span>
            </label>
            <textarea
              name="body"
              value={formData.body}
              onChange={handleChange}
              placeholder="質問の詳細を入力"
              rows={4}
              className="textarea textarea-bordered w-full"
              required
            />
          </div>

          {/* 質問タイプ */}
          <div className="form-control">
            <label className="label">
              <span className="label-text font-semibold">質問タイプ</span>
            </label>
            <select
              name="question_type"
              value={formData.question_type}
              onChange={handleChange}
              className="select select-bordered w-full"
            >
              <option value="text">テキスト（自由記述）</option>
              <option value="choice">選択肢</option>
              <option value="rating">評価（1〜5点）</option>
            </select>
          </div>

          {/* 選択肢 */}
          {needsChoices && (
            <div className="form-control">
              <label className="label">
                <span className="label-text font-semibold">選択肢</span>
              </label>
              <div className="space-y-2">
                {formData.choices.map((choice, index) => (
                  <div key={index} className="flex gap-2 items-center">
                    <input
                      type="text"
                      value={choice.label}
                      onChange={(e) => handleChoiceChange(index, e.target.value)}
                      placeholder={`選択肢 ${index + 1}`}
                      className="input input-bordered flex-1"
                    />
                    <button
                      type="button"
                      onClick={() => removeChoice(index)}
                      className="btn btn-ghost btn-sm text-error"
                    >
                      削除
                    </button>
                  </div>
                ))}
                <button
                  type="button"
                  onClick={addChoice}
                  className="btn btn-outline btn-sm"
                >
                  + 選択肢を追加
                </button>
              </div>
            </div>
          )}

          {/* ステータス */}
          <div className="form-control">
            <label className="label">
              <span className="label-text font-semibold">ステータス</span>
            </label>
            <select
              name="status"
              value={formData.status}
              onChange={handleChange}
              className="select select-bordered w-full"
            >
              <option value="draft">下書き</option>
              <option value="published">公開</option>
              <option value="closed">クローズ</option>
            </select>
          </div>

          {/* ボタン */}
          <div className="card-actions justify-end gap-2 mt-6">
            {onCancel && (
              <button
                type="button"
                onClick={onCancel}
                className="btn btn-ghost"
              >
                キャンセル
              </button>
            )}
            <button
              type="submit"
              disabled={submitting}
              className="btn btn-primary"
            >
              {submitting ? <span className="loading loading-spinner loading-sm" /> : null}
              {isEdit ? '更新する' : '作成する'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default QuestionForm;
