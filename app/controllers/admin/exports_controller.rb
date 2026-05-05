# frozen_string_literal: true

module Admin
  class ExportsController < ApplicationController
    before_action :authenticate_user!
    before_action :authorize_admin!
    before_action :set_question

    # GET /admin/questions/:question_id/export/pdf
    def pdf
      pdf_doc = generate_pdf
      send_data pdf_doc.render,
                filename: "#{sanitize_filename(@question.title)}_#{Date.today}.pdf",
                type: 'application/pdf',
                disposition: 'attachment'
    end

    # GET /admin/questions/:question_id/export/csv
    def csv
      csv_data = generate_csv
      send_data csv_data,
                filename: "#{sanitize_filename(@question.title)}_#{Date.today}.csv",
                type: 'text/csv; charset=UTF-8',
                disposition: 'attachment'
    end

    private

    def set_question
      current_company = current_user.owned_companies.first || current_user.companies.first
      # id ではなく question_id を使う場合がある（ルーティングの定義次第）
      # resources :questions { member { ... } } の場合 params[:id] が Question ID
      question_id = params[:question_id] || params[:id]
      @question = current_company ? current_company.questions.find(question_id) : nil
      unless @question
        render json: { error: 'Question not found' }, status: :not_found
      end
    rescue ActiveRecord::RecordNotFound
      render json: { error: 'Question not found' }, status: :not_found
    end

    def generate_pdf
      require 'prawn'
      require 'prawn/table'

      # 日本語フォントパス
      font_path = '/usr/share/fonts/truetype/fonts-japanese-gothic.ttf'
      has_japanese_font = File.exist?(font_path)

      # フォントがない場合に文字列をASCII互換に変換するヘルパー
      enc = ->(str) {
        return str.to_s if has_japanese_font
        str.to_s.encode('WINDOWS-1252', invalid: :replace, undef: :replace, replace: '?')
      }

      Prawn::Document.new(page_size: 'A4', margin: [40, 40, 40, 40]) do |pdf|
        if has_japanese_font
          pdf.font_families.update('Japanese' => { normal: font_path })
          pdf.font 'Japanese'
        end

        # タイトル
        pdf.text enc.call(@question.title), size: 18, style: :bold
        pdf.move_down 10
        pdf.text enc.call(@question.body), size: 12
        pdf.move_down 20

        # 質問情報
        pdf.text enc.call("回答数: #{@question.answers.count}"), size: 12
        pdf.text enc.call("ステータス: #{@question.status}"), size: 12
        pdf.text enc.call("締切日: #{@question.deadline&.strftime('%Y/%m/%d') || '未設定'}"), size: 12
        pdf.move_down 20

        # 回答一覧
        pdf.text enc.call('回答一覧'), size: 14, style: :bold
        pdf.move_down 10

        answers = @question.answers.order(created_at: :asc)
        if answers.any?
          table_data = [[enc.call('No.'), enc.call('回答内容'), enc.call('投稿日時')]]
          answers.each_with_index do |answer, idx|
            body = enc.call(answer.body.to_s.truncate(200))
            date = enc.call(answer.created_at.strftime('%Y/%m/%d %H:%M'))
            table_data << [(idx + 1).to_s, body, date]
          end

          pdf.table(table_data,
                    header: true,
                    width: pdf.bounds.width,
                    cell_style: { size: 10, padding: [5, 8] },
                    row_colors: ['FFFFFF', 'F5F5F5']) do |t|
            t.row(0).font_style = :bold
            t.row(0).background_color = '4472C4'
            t.row(0).text_color = 'FFFFFF'
            t.column(0).width = 40
            t.column(2).width = 110
          end
        else
          pdf.text enc.call('回答はまだありません。'), size: 12
        end

        # 統計情報（選択肢型・評価型の場合）
        if @question.choice? || @question.rating?
          pdf.move_down 20
          pdf.text enc.call('回答集計'), size: 14, style: :bold
          pdf.move_down 10

          choice_data = [[enc.call('選択肢'), enc.call('回答数'), enc.call('割合(%)')]]
          total = @question.answers.count
          @question.choices.each do |choice|
            count = choice.answers.count
            rate = total > 0 ? (count.to_f / total * 100).round(1) : 0
            choice_data << [enc.call(choice.label), count.to_s, "#{rate}%"]
          end

          pdf.table(choice_data,
                    header: true,
                    width: 300,
                    cell_style: { size: 10, padding: [5, 8] }) do |t|
            t.row(0).font_style = :bold
            t.row(0).background_color = '4472C4'
            t.row(0).text_color = 'FFFFFF'
          end
        end
      end
    end

    def generate_csv
      require 'csv'

      bom = "\xEF\xBB\xBF"
      answers = @question.answers.order(created_at: :asc)

      csv_string = CSV.generate do |csv|
        # ヘッダー
        csv << ['No.', '回答内容', '投稿日時']

        answers.each_with_index do |answer, idx|
          csv << [
            idx + 1,
            answer.body,
            answer.created_at.strftime('%Y/%m/%d %H:%M')
          ]
        end
      end

      bom + csv_string
    end

    def sanitize_filename(filename)
      filename.to_s.gsub(/[^\x00-\x7F]/, '_').gsub(/[\/:*?"<>|]/, '_').truncate(50)
    end

    def authorize_admin!
      redirect_to root_path, status: :forbidden unless current_user.admin?
    end
  end
end
