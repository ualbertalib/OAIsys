module Oaisys::SetIdHelper
  def set_id(xml:, id:)
    return if id.blank?

    xml.setSpec id
  end
end
