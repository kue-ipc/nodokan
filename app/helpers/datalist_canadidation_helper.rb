module DatalistCanadidationHelper
  def datalist_canadidation(
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
      class: ["datalist-canadidation", "d-none"],
      "data-params": params.to_json,
    )
  end
end
