module Questions
  class ShowPresenter < ApplicationPresenter
    def initialize(view_context, question)
      super(view_context)
      @question = question
    end

    def json_props
      {
        authenticityToken: view.form_authenticity_token,
        questions: question_data,
        answers: answer_data,
        comments: comments,
        userData: user_data
      }.to_json
    end

    def question_data
      {
        id: @question.id,
        title: @question.title,
        description: @question.description,
        userId: @question.user_id,
        createdAt: created_at(@question)
      }
    end

    def answer_data
      @answer_data ||=
        @question.answers.select(:id, :description, :user_id, :created_at).map do |answer|
          {
            id: answer.id,
            description: answer.description,
            userId: answer.user_id,
            createdAt: created_at(answer)
          }
        end
    end

    def comments
      @comments ||=
        @question.comments.map(&method(:comment_data)) + comments_for_answers
    end

    def comments_for_answers
      Comment.where(commentable_type: 'Answer', commentable_id: @answer_data.pluck(:id)).map(&method(:comment_data))
    end

    def comment_data(comment)
      {
        id: comment.id,
        value: comment.value,
        userId: comment.user_id,
        commentableType: comment.commentable_type,
        commentableId: comment.commentable_id
      }
    end

    def user_data
      user_ids = [@question.id, answer_data.pluck(:userId), comments.pluck(:userId)].flatten.uniq

      UserProfile.where(user_id: user_ids, school: current_school).includes([:avatar_attachment, user: :faculty]).map do |user_profile|
        {
          userId: user_profile.user_id,
          name: user_profile.name,
          avatarUrl: avatar_url(user_profile),
          title: title(user_profile)
        }
      end
    end

    private

    def created_at(object)
      object.created_at.to_formatted_s(:long)
    end

    def title(user_profile)
      title = user_profile.title
      title_text = title.present? ? ", #{title}" : ""
      if user_profile.user.faculty.any?
        "Faculty #{title_text}"
      else
        "Student #{title_text}"
      end
    end

    def avatar_url(user_profile)
      if user_profile.avatar.attached?
        view.url_for(user_profile.avatar_variant(:mid))
      else
        user_profile.initials_avatar(:square)
      end
    end
  end
end
