module ConfirmationsHelper
  def confirmation_question_radio_buttons(form, name, count: nil,
    required: false)
    confirmation_question_group(form, name, count: nil) do
      t_enums(name.to_s.pluralize.intern, Confirmation).map { |key, message|
        form.radio_button(name, key, label: message, required: required,
          data: {node_confirmation_target: name})
      }.inject(:+)
    end
  end

  def confirmation_question_group(form, name, count: nil, &block)
    form.form_group(name,
      label: {
        text: confirmation_question_label(name, count: count),
      },
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      &block)
  end

  def confirmation_question_label(name, count: nil)
    if count
      safe_join([
        tag.strong(t("messages.question_with_number", count: count)),
        " ",
        t(name, scope: "messages.node_confirm_questions"),
      ])
    else
      safe_join([
        tag.strong(t("messages.question")),
        " ",
        t(name, scope: "messages.node_confirm_questions"),
      ])
    end
  end
end
