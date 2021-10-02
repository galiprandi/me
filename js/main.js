const attributeName = 'tr'
const separator = '|'
window.ln = 'en'
let i18n = {}

document.addEventListener('DOMContentLoaded', initApp)

async function initApp() {
  i18n = await loadTranslations()
  changeLanguage(navigator.language.split('-')[0] || 'en')
}

const changeLanguage = lang => {
  window.ln = lang
  translate()

  // Render devs
  populateWithList(
    i18n.devs[window.ln] || [],
    3,
    'developments-container',
    createDevelopmentCard,
    i18n.miscellany[window.ln][10] || 'Other projects...'
  )

  // Render employment
  populateWithList(
    i18n.employment[window.ln] || [],
    3,
    'employment-container',
    createEmploymentCard,
    i18n.miscellany[window.ln][11] || 'Other jobs...'
  )
}

window.toggleLanguage = () => {
  window.ln === 'en' ? changeLanguage('es') : changeLanguage('en')
}

// Load translations from file
const loadTranslations = async () => {
  const response = await fetch('../translate.json')
  if (!response.ok) return null
  return await response.json()
}

const translate = () => {
  const nodeList = document.querySelectorAll(`[data-${attributeName}]`)
  nodeList.forEach(async node => {
    const value = node.getAttribute(`data-${attributeName}`)
    if (value.includes(separator)) {
      // Return array positions
      const [key, index] = value.split(separator)
      if (!key in i18n || !i18n[key][window.ln]) return
      const text = i18n[key][window.ln][index] || false
      if (text) node.textContent = text
    } else {
      const text = i18n[value][window.ln] || false
      if (text) node.textContent = text
    }
  })
}

const populateWithList = (
  list,
  limit = 0,
  containerId,
  renderFunction,
  seeMoreLabel = 'See more...'
) => {
  const container = document.getElementById(containerId)
  if ((!list?.length, !container, !renderFunction)) return
  if (limit === 0) limit = list.length

  const limitList = list.slice(0, limit)
  const restList = list.slice(limit)

  container.innerHTML = ''
  limitList.map(item => container.appendChild(renderFunction(item)))

  // See more
  if (!!restList.length) {
    const details = document.createElement('details')
    const summary = document.createElement('summary')

    details.classList.add('hide', 'screen')
    summary.classList.add('see-more')
    summary.textContent = seeMoreLabel
    details.appendChild(summary)

    restList.map(item => details.appendChild(renderFunction(item)))
    container.appendChild(details)
  }
}

const createDevelopmentCard = props => {
  const { img, title, desc, tools, web, code, about } = props
  const template = document.getElementById('dev-card').cloneNode(true)
  const card = template.content
  card.querySelector
  card.querySelector('.dev-card-img').src = img
  card.querySelector('.dev-card-img').title = title
  card.querySelector('.dev-card-img').alt = title
  card.querySelector('.dev-card-title').textContent = title
  card.querySelector('.dev-card-desc').textContent = desc
  card.querySelector('.dev-card-tools').textContent = tools
  if (web) {
    card.querySelector('.dev-card-web').href = web
    card.querySelector('.dev-card-web').textContent = web.replace(
      'https://',
      ''
    )
  }
  if (code) {
    card.querySelector('.dev-card-code').href = code
    card.querySelector('.dev-card-code').textContent = code.replace(
      'https://',
      ''
    )
  }
  if (about) {
    card.querySelector('.dev-card-about').textContent = about
    card.querySelector('.dev-card-see-more').textContent =
      i18n.miscellany[window.ln][8]
  } else card.querySelector('details').remove()

  return card
}

const createEmploymentCard = props => {
  const { company, period, location, title, desc, web } = props
  const template = document.getElementById('emp-card').cloneNode(true)
  const card = template.content
  card.querySelector(
    '.emp-card-head'
  ).textContent = `${company} | ${period} | ${location}`
  card.querySelector('.emp-card-title').textContent = title
  card.querySelector('.emp-card-desc').textContent = desc
  if (web) {
    card.querySelector('.emp-card-web').href = web
    card.querySelector('.emp-card-web').textContent = web
  } else card.querySelector('.emp-card-web').remove()
  return card
}
