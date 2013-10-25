class SparcFormBuilder < ActionView::Helpers::FormBuilder
  include NestedForm::BuilderMixin

  # Formats a number to two decimal places, if valid
  # doesn't touch the value if invalid
  def currency_text_field(method_name, options={})
    options[:class] = "currency #{options[:class]}"

    if numerically_validated?(method_name) && valid?(method_name)
      options[:value] = @template.number_with_precision(
        ActionView::Helpers::InstanceTag.value_before_type_cast(object, method_name.to_s),
        precision: 2,
        significant: false
      )
    end

    text_field(method_name, options)
  end

private
  def numerically_validated?(method_name)
    object.class.validators_on(method_name).any? { |v| v.kind_of? ActiveModel::Validations::NumericalityValidator }
  end

  def valid?(method_name)
    object.errors[method_name].blank?
  end
end