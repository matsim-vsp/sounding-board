# VSP Sounding Board

Live at <https://vsp.berlin/sounding-board>

Add new boards on the VSP public-svn at

- `public-svn/matsim/scenarios/countries/de/berlin/projects/sounding-board/`

### Build instructions

Requires NodeJS 16.x and yarn: Install Node for your platform, and then `npm install -g yarn`

- Clone the repo
- `yarn install`
- `yarn serve` to run a local dev server
- Pushing to `master` branch automatically builds and deploys on URL above.

The code assumes the site `prefix` is set to `/sounding-board`, this is added to every URL. To move
the site to a different prefix, edit two files:

- `public/404.html`
- `vite.config.js`


### Change the default URL

To change the URL that gets loaded if user visits https://vsp.berlin/sounding-board

- edit `sounding-board/src/router.js` and find the "catch-all" redirect, currently at line 28.
- it is current set to `/berlin/config` at time of this writing.

You can edit the file directly on GitHub:
- https://github.com/matsim-vsp/sounding-board/blob/master/sounding-board/src/router.ts


Have fun,

Billy
