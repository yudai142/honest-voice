require 'rails_helper'

RSpec.describe AnalysisService do
  let(:company) { create(:company) }
  let(:question) { create(:question, :text_type, :published, company: company) }
  let(:client) { instance_double(Anthropic::Client) }
  let(:message_text) do
    {
      sentiment_summary: '全体として前向きだが、業務量に改善要望がある',
      keywords: ['働き方', '業務量', 'コミュニケーション'],
      average_rating: 4.2,
      total_responses: 5
    }.to_json
  end
  let(:api_response) do
    {
      'content' => [
        { 'type' => 'text', 'text' => message_text }
      ]
    }
  end

  before do
    5.times do |index|
      create(:answer, question: question, company: company, body: "回答#{index}")
    end
  end

  describe '#call' do
    it '回答5件以上で QuestionAnalysis を completed まで更新する' do
      allow(client).to receive(:messages).and_return(double(create: api_response))

      analysis = described_class.new(question: question, client: client).call

      expect(analysis).to be_completed
      expect(analysis.sentiment_summary).to include('前向き')
      expect(analysis.keywords_array).to include('働き方', '業務量')
      expect(analysis.average_rating).to eq(4.2)
      expect(analysis.total_responses).to eq(5)
      expect(analysis.analyzed_at).to be_present
    end

    it '回答が5件未満なら pending のまま処理しない' do
      question.answers.limit(2).destroy_all
      allow(client).to receive(:messages)

      analysis = described_class.new(question: question, client: client).call

      expect(analysis).to be_pending
      expect(client).not_to have_received(:messages)
    end

    it 'API エラー時は failed に遷移する' do
      allow(client).to receive(:messages).and_raise(StandardError, 'api failure')

      analysis = described_class.new(question: question, client: client).call

      expect(analysis).to be_failed
    end
  end
end