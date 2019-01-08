# Helsinki - Maailman toimivin kaupunki

Maailman toimivin kaupunki is a campaign site that will be available at the
following URL:

http://www.maailmantoimivinkaupunki.fi/

This website is built on top of Decidim, free Open-Source participatory
democracy, citizen participation and open government for cities and
organizations.

Read more about [Decidim](https://github.com/decidim/decidim).

This instance of Decidim has been customized from the main Decidim version in
order to meet the requirements. The campaign site only consists of a single
Decidim process and a single module (proposals) within it, nothing else is
needed from Decidim.

The following customizations have been made to Decidim for instance:

- Integrated to Helsinki authentication platform, Tunnistamo
- Customized UI with Helsinki layout designed particularly for this campaign
- Customized the URL structure for the application in order to serve only a
  single process and a single module from that (i.e. the routes)
- Customized the proposals module in order to streamline the proposals feature

## Development

Please follow Decidim's getting started guide at:

https://github.com/decidim/decidim/blob/master/docs/getting_started.md

Check the database you need for development at `config/database.yml`. You can
also edit the database configs through the
[`dotenv-rails`](https://rubygems.org/gems/dotenv-rails/versions/2.1.1) gem in
case you want to.

Please note that you need to seed the development application with sample data
in order to work with it. Follow the getting started instructions to achieve
this.

### Comments component

The comments component works as a standalone React application which is complied
for the Rails assets pipeline. Every time making changes to the app, please
recompile the application.

The application sources live at `vendor/decidim-comments`. The sources are
compiled locally to the app directory.

Follow Decidim's own instructions regarding developing the comments component:

https://github.com/decidim/decidim/tree/master/decidim-comments

In short:

- Install npm dependencies with:
  `npm i`
- During development, run the webpack watcher with (it will rebuild the app
  every time you make changes):
  `npm start`
- Make your changes to the React app at `vendor/decidim-comments`
- Test it in the browser
- Once you are finished, stop the watcher and run tests with:
  `npm test`
- If some tests fail, fix them
- Build the production version of the application bundle with:
  `npm run build:prod`
- Commit your changes along with the new bundle created at
  `app/assets/javascripts/decidim/comments/bundle.js`


## Deploy the application

You will need to do some steps before having the app working properly once you've deployed it:

1. Open a Rails console in the server: `bundle exec rails console`
2. Create a System Admin user:
```ruby
user = Decidim::System::Admin.new(email: <email>, password: <password>, password_confirmation: <password>)
user.save!
```
3. Visit `<your app url>/system` and login with your system admin credentials
4. Create a new organization. Check the locales you want to use for that organization, and select a default locale.
5. Set the correct default host for the organization, otherwise the app will not work properly. Note that you need to include any subdomain you might be using.
6. Fill the rest of the form and submit it.

You're good to go!
