import React, { useState } from 'react';

/**
 * AnswerForm - 回答フォームコンポーネント
 * Member が質問に対して匿名で回答するための React フォーム
 * question_type に応じて入力形式が切り替わる
 */
const AnswerForm = ({ question, sessionId, onSuccess }) => {
  const [selectedChoiceId, setSelectedChoiceId] = useState('');
  const [ratingValue, setRatingValue] = useState(0);
  const [bodyText, setBodyText] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState([]);
  const [submitted, setSubmitted] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setErrors([]);

    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;

    const payload = {
      answer: {
        session_id: sessionId,
        body: question.question_type === 'text' ? bodyText : null,
        choice_id: question.question_type === 'choice' ? selectedChoiceId : null,
        rating_value: question.question_type === 'rating' ? ratingValue : null,
      },
    };

    try {
      const res = await fetch(`/questions/${question.id}/answers`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken,
        },
        body: JSON.stringify(payload),
      });

      const data = await res.json();

      if (!res.ok) {
        setErrors(data.errors || ['回答の送信に失敗しました。']);
      } else {
        setSubmitted(true);
        onSuccess?.(data.answer);
      }
    } catch {
      setErrors(['通信エラーが発生しました。']);
    } finally {
      setSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <div className="alert alert-success">
        <svg xmlns="http://www.w3.org/2000/svg" className="stroke-current shrink-0 h-6 w-6" fill="none" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        <span>回答を送信しました。ありがとうございました。</span>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} className="space-y-6">
      {errors.length > 0 && (
        <div className="alert alert-error">
          <ul className="list-disc list-inside">
            {errors.map((err, i) => (
              <li key={i}>{err}</li>
            ))}
          </ul>
        </div>
      )}

      {/* テキスト型 */}
      {question.question_type === 'text' && (
        <div className="form-control">
          <label className="label">
            <span className="label-text font-semibold">回答</span>
            <span className="label-text-alt text-base-content/50">匿名</span>
          </label>
          <textarea
            value={bodyText}
            onChange={(e) => setBodyText(e.target.value)}
            rows={5}
            placeholder="ここに回答を入力してください"
            className="textarea textarea-bordered w-full"
            required
          />
        </div>
      )}

      {/* 選択肢型 */}
      {question.question_type === 'choice' && (
        <div className="form-control">
          <p className="label-text font-semibold mb-3">選択肢を選んでください</p>
          <div className="space-y-2">
            {(question.choices || []).map((choice) => (
              <label key={choice.id} className="label cursor-pointer justify-start gap-4 py-2">
                <input
                  type="radio"
                  name="choice_id"
                  value={choice.id}
                  checked={selectedChoiceId === String(choice.id)}
                  onChange={() => setSelectedChoiceId(String(choice.id))}
                  className="radio radio-primary"
                  required
                />
                <span className="label-text text-base">{choice.label}</span>
              </label>
            ))}
          </div>
        </div>
      )}

      {/* 評価型 */}
      {question.question_type === 'rating' && (
        <div className="form-control">
          <p className="label-text font-semibold mb-3">評価を選んでください</p>
          <div className="bg-base-200 rounded-xl p-4 border border-base-300 inline-flex flex-col gap-2">
            <div className="flex gap-1">
              {[1, 2, 3, 4, 5].map((value) => (
                <button
                  key={value}
                  type="button"
                  onClick={() => setRatingValue(value)}
                  className={`btn btn-ghost btn-sm text-2xl p-1 ${ratingValue >= value ? 'text-warning' : 'text-base-content/30'}`}
                  aria-label={`${value} 点`}
                >
                  ★
                </button>
              ))}
            </div>
            {ratingValue > 0 && (
              <p className="text-sm text-center text-base-content/70">{ratingValue} 点を選択中</p>
            )}
          </div>
          <p className="text-xs text-base-content/70 mt-2">1（低い）〜5（高い）で評価してください</p>
        </div>
      )}

      <div className="flex justify-end">
        <button
          type="submit"
          disabled={submitting}
          className="btn btn-primary"
        >
          {submitting ? <span className="loading loading-spinner loading-sm" /> : null}
          回答を送信
        </button>
      </div>
    </form>
  );
};

export default AnswerForm;
