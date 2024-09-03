module ConfirmationsHelper
  # for enum
  def confirmation_question_enum(form, name, count: nil, excludes: [],
    action: nil, **)
    list = t_enums(name, Confirmation).except(*excludes).to_a
    form.collection_radio_buttons(name, list, :first, :second,
      label: {text: confirmation_question_label(name, count:)},
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      data: {
        node_confirmation_target: name.to_s.camelize(:lower),
        action: action && "node-confirmation##{action}",
      },
      **)
  end

  # for bitwise
  def confirmation_question_bitwise(form, name, count: nil, excludes: [],
    action: nil, **)
    list = t_bitwises(name, Confirmation).except(*excludes).to_a
    form.collection_check_boxes(name, list, :first, :second,
      label: {text: confirmation_question_label(name, count:)},
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      data: {
        node_confirmation_target: name.to_s.camelize(:lower),
        action: action && "node-confirmation##{action}",
      },
      **)
  end

  def confirmation_question_group(form, name, count: nil, required: false,
    **, &)
    label_class =
      if required
        "form-label required"
      else
        "form-label"
      end
    form.form_group(name,
      label: {
        text: confirmation_question_label(name, count:),
        class: label_class,
      },
      help: raw(t(name, scope: "messages.node_confirm_helps", default: nil)),
      **, &)
  end

  def confirmation_question_label(name, count: nil)
    if count
      safe_join([
        tag.strong(t("messages.question_with_number", count:)),
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
