import React, { useEffect, useState } from 'react';

const ROLE_OPTIONS = ['owner', 'manager', 'member', 'viewer'];

export default function MemberRoleManager({ companyId }) {
  const [members, setMembers] = useState([]);

  const fetchMembers = async () => {
    const response = await fetch(`/admin/companies/${companyId}/company_members`);
    if (!response.ok) return;

    const data = await response.json();
    setMembers(data.members || []);
  };

  const updateRole = async (memberId, role) => {
    const response = await fetch(`/admin/companies/${companyId}/company_members/${memberId}`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
      },
      body: JSON.stringify({ company_member: { role } })
    });

    if (!response.ok) return;
    await fetchMembers();
  };

  const removeMember = async (memberId) => {
    const response = await fetch(`/admin/companies/${companyId}/company_members/${memberId}`, {
      method: 'DELETE',
      headers: {
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content || ''
      }
    });

    if (!response.ok) return;
    await fetchMembers();
  };

  useEffect(() => {
    fetchMembers();
  }, []);

  return (
    <div className="card bg-base-100 shadow-xl mt-6">
      <div className="card-body">
        <h2 className="card-title">メンバー権限管理</h2>

        <div className="overflow-x-auto">
          <table className="table table-zebra">
            <thead>
              <tr>
                <th>名前</th>
                <th>メール</th>
                <th>ロール</th>
                <th>操作</th>
              </tr>
            </thead>
            <tbody>
              {members.map((member) => (
                <tr key={member.id}>
                  <td>{member.user?.name || '(未設定)'}</td>
                  <td>{member.user?.email}</td>
                  <td>
                    <select
                      className="select select-bordered select-sm"
                      value={member.role}
                      onChange={(e) => updateRole(member.id, e.target.value)}
                    >
                      {ROLE_OPTIONS.map((role) => (
                        <option key={role} value={role}>{role}</option>
                      ))}
                    </select>
                  </td>
                  <td>
                    <button className="btn btn-sm btn-error" onClick={() => removeMember(member.id)}>
                      除外
                    </button>
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
