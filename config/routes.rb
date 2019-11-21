class PMHConstraint

  PMHVERBS = %w[Identify ListSets ListMetadataFormats ListRecords GetRecord ListIdentifiers].freeze

  def matches?(request)
    request.query_parameters.key?(:verb) && PMHVERBS.include?(request.query_parameters[:verb])
  end

end

class BadVerbConstraint < PMHConstraint

  def matches?(request)
    !super
  end

end

class NoVerbConstraint < PMHConstraint

  def matches?(request)
    !request.query_parameters.key?(:verb)
  end

end

class IdentifyConstraint < PMHConstraint

  def matches?(request)
    super && request.query_parameters[:verb] == 'Identify'
  end

end

class ListSetsConstraint < PMHConstraint

  def matches?(request)
    super && request.query_parameters[:verb] == 'ListSets'
  end

end

class ListMetadataFormatsConstraint < PMHConstraint

  def matches?(request)
    super && request.query_parameters[:verb] == 'ListMetadataFormats'
  end

end

class ListRecordsConstraint < PMHConstraint

  def matches?(request)
    super && request.query_parameters[:verb] == 'ListRecords'
  end

end

class GetRecordConstraint < PMHConstraint

  def matches?(request)
    super && request.query_parameters[:verb] == 'GetRecord'
  end

end

class ListIdentifiersConstraint < PMHConstraint

  def matches?(request)
    super && request.query_parameters[:verb] == 'ListIdentifiers'
  end

end

Oaisys::Engine.routes.draw do
  match '/', to: 'pmh#bad_verb', via: [:get, :post], constraints: BadVerbConstraint.new
  match '/', to: 'pmh#no_verb', via: [:get, :post], constraints: NoVerbConstraint.new
  match '/', to: 'pmh#identify', via: [:get, :post], constraints: IdentifyConstraint.new
  match '/', to: 'pmh#list_sets', via: [:get, :post], constraints: ListSetsConstraint.new
  match '/', to: 'pmh#list_metadata_formats', via: [:get, :post], constraints: ListMetadataFormatsConstraint.new
  match '/', to: 'pmh#list_records', via: [:get, :post], constraints: ListRecordsConstraint.new
  match '/', to: 'pmh#get_record', via: [:get, :post], constraints: GetRecordConstraint.new
  match '/', to: 'pmh#list_identifiers', via: [:get, :post], constraints: ListIdentifiersConstraint.new
end
