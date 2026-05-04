require 'rails_helper'

RSpec.describe AnalysisJob, type: :job do
  let(:question) { create(:question, :text_type, :published) }
  let(:service) { instance_double(AnalysisService, call: true) }

  it 'AnalysisService を呼び出す' do
    allow(AnalysisService).to receive(:new).with(question: question).and_return(service)

    described_class.perform_now(question.id)

    expect(service).to have_received(:call)
  end
end