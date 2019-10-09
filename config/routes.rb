class PMHConstraint
  PMHVERBS = %w(Identify ListSets ListMetadataFormats ListRecords GetRecord ListIdentifiers).freeze

  def matches?(request)
    request.query_parameters.key?(:verb) && PMHVERBS.include?(request.query_parameters[:verb])
  end
end

class BadVerbConstraint < PMHConstraint
  def matches?(request)
    !super
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
  match '/', to: 'pmh#list_identifiers', via: [:get, :post], constraints: ListIdentifiersConstraint.new
end
