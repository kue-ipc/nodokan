import simpleIcons from 'simple-icons'

document.addEventListener 'turbolinks:load', ->
  for el in document.querySelectorAll('i.si')
    iconName = null
    otherClassList = []
    for name in el.classList
      name = name.toLowerCase()
      continue if name == 'si'

      result = /^si-(.+)$/.exec(name)
      if result?
        iconName = result[1]
      else
        otherClassList.push(name)

    unless iconName?
      console.warn("has not si-class #{el}")
      continue

    icon = simpleIcons.get(iconName)
    unless icon?
      console.warn("no icon in SimpleIcons: #{iconName}")
      continue

    console.log(icon)

    svgEl = document.createElementNS('http://www.w3.org/2000/svg', 'svg')
    svgEl.style.height = '1em'
    svgEl.style.width = '1em'
    svgEl.setAttribute('role', 'img')
    svgEl.setAttribute('viewBox', '0 0 24 24')
    pathEl = document.createElementNS('http://www.w3.org/2000/svg', 'path')
    pathEl.setAttribute('d', icon.path)
    svgEl.appendChild(pathEl)

    el.parentNode.replaceChild(svgEl, el)

, false


