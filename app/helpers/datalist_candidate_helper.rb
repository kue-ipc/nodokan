module DatalistCandidateHelper
  def datalist_candidate(
    name,
    target,
    url,
    parents: [],
    **opts
  )
    params = {
      name: name,
      target: target,
      url: url,
      parents: parents,
      **opts,
    }
    attr_name = [*parents, name, target].join("_")
    tag.div(
      id: "#{attr_name}-app",
      class: ["datalist-candidate", "d-none"],
      "data-params": params.to_json)
  end
end
