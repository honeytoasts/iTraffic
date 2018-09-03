import querystring from 'querystring'
import fetch from 'isomorphic-fetch'

export default function (
    type = 'GET',
    api_uri,
    param = {},
    header = {}
  ) {
  const uri = `${api_uri}`
  const qs = querystring.stringify(param)
  const init = {
    method: type,
    headers: {
      ...header,
      'Accept': 'application/json',
      'Content-Type': 'application/json'
    }
  }
  // console.log(uri)
  // console.log(qs);

  switch (type) {
    /*
      GET, PATCH, DELETE occasionally need querystring in their URI, which is the part after question mark.
      For example, https://api.github.com/search/repositories?q={query}{&page,per_page,sort,order}
                                  ⬆︎querystring starts from here
      When it comes to POST, instead of querystring but 'body' is what it needs.
     */
    case 'GET':
    case 'PATCH':
    case 'DELETE':
      console.log(`${uri}${qs ? '?' : ''}${qs}`)
      return fetch(`${uri}${qs ? '?' : ''}${qs}`, init)
        .then((res) => res.json())
        .then((json) => json)
    case 'POST':
      const PostInit = {
        ...init,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: qs
      }
      return fetch(uri, PostInit)
        .then((res) => res.json())
        .then((json) => json)
  }
}
