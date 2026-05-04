import React, { useEffect, useState } from 'react';

export default function InviteTokenManager({ companyId }) {
  const [tokens, setTokens] = useState([]);
  const [maxUses, setMaxUses] = useState(1);
  const [loading, setLoading] = useState(false);

  const fetchTokens = async () => {
    const response = await fetch(`/admin/companies/${companyId}/invite_tokens`);
    if (!response.ok) return;

    const data = await response.json();
    setTokens(data.invite_tokens || []);
  };

  const createToken = async () => {
    setLoading(true);
    const response = await fetch(`/admin/companies/${companyId}/invite_tokens`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
      },
      body: JSON.stringify({ invite_token: { max_uses: Number(maxUses) } })
    });

    setLoading(false);
    if (!response.ok) return;
    await fetchTokens();
  };

  const deactivateToken = async (id) => {
    const response = await fetch(`/admin/companies/${companyId}/invite_tokens/${id}/deactivate`, {
      method: 'PATCH',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
      }
    });

    if (!response.ok) return;
    await fetchTokens();
  };

  useEffect(() => {
    fetchTokens();
  }, []);

  return (
    <div className="card bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title">招待URL管理</h2>

        <div className="flex items-center gap-3">
          <label className="label">最大利用回数</label>
          <input
            className="input input-bordered w-32"
            type="number"
            min={1}
            value={maxUses}
            onChange={(e) => setMaxUses(e.target.value)}
          />
          <button className={`btn btn-primary ${loading ? 'btn-disabled' : ''}`} onClick={createToken}>
            招待URLを発行
          </button>
        </div>

        <div className="overflow-x-auto mt-4">
          <table className="table table-zebra">
            <thead>
              <tr>
                <th>URL</th>
                <th>状態</th>
                <th>利用回数</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {tokens.map((token) => (
                <tr key={token.id}>
                  <td className="max-w-xl truncate">{token.invite_url}</td>
                  <td>{token.active ? '有効' : '無効'}</td>
                  <td>{token.use_count} / {token.max_uses}</td>
                  <td>
                    {token.active && (
                      <button className="btn btn-sm btn-warning" onClick={() => deactivateToken(token.id)}>
                        無効化
                      </button>
                    )}
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
