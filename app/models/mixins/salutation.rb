module Mixins::Salutation
  if not (const_defined?(:SALUTATIONS) or const_defined?("SALUTATIONS"))
    SALUTATIONS = I18n.translate('shared.salutations')
  end
end
