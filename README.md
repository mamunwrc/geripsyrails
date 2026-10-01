# GeriPSY

GeriPSY uses the following:
* Ruby v2.7.7
* Rails v5.1.1
* Postgres (v14.x on production)
* Sidekiq
  * Redis

## Data Concerns

Production is hosted on the HIPAA-compliant [Aptible](https://www.aptible.com/security-compliance) platform and the database contains PHI/PII.  Staging contains an anonymized version of the data.

## Development

Once gems are installed, you should be able to set up a blank environment with the following:
* `bundle exec rake db:setup`
* `bundle exec rake db:seed`

To use a version of the staging data, you can get the URI from Heroku [here](https://data.heroku.com/datastores/6c547039-bc02-450d-a5f2-50943438564f#administration):

* If you have local data:
  * `bundle exec rake db:drop db:create`
* `pg_dump -f geripsy_staging.dump [uri]`
* `psql geripsy_development < geripsy_staging.dump`

These environment variables need to be set to test certain parts of the project.  See examples on staging for testing locally.
* [Claim MD](https://www.claim.md/) (our billing system)
  * CLAIM_MD_SFTP_HOST
  * CLAIM_MD_SFTP_USER
  * CLAIM_MD_SFTP_PASS
* [SendInc](https://www.sendinc.com/) (our encrypted email system)
  * SENDINC_EMAIL
  * SENDINC_PW
  * ADMIN_EMAIL
  * DEBUG_EMAIL


## Deployment

### Prerequisites

Staging is hosted on [Heroku](https://heroku.com/), production is hosted on [Aptible](https://www.aptible.com/). Both require a CLI installed to handle login and a git endpoint to handle deployment.

If updating frontend code, also update `GeriPsy::Application::VERSION`.  This will ensure anyone with an old open tab will force-refresh and have an up-to-date environment.

### Staging

* Install [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli#install-the-heroku-cli)
* Add the git remote
  * `git remote add heroku https://git.heroku.com/geripsy-staging.git`
* Login (if necessary)
  * `heroku login`
* Deploy
  * `git push heroku master`

### Production

* Install [Aptible CLI](https://www.aptible.com/docs/cli#installing-the-aptible-cli)
* Add the git remote
  * `git remote add aptible git@beta.aptible.com:geripsy/geripsy-pro.git`
* Login (if necessary)
  * `aptible login`
* Deploy
  * `git push aptible master`

## Common Issues

### Billing failure

Occasionally something goes wrong with the billing process and no claims will be sent to Claim MD.
On a typical error an email will be sent to the ADMIN_EMAIL (the client) and DEBUG_EMAIL (the developer), but this doesn't cover every situation.
In these cases, you want to figure out the affected dates (start/end), mark the encounters as "unshipped", then manually run a shipping job to see the error firsthand and make the appropriate updates.

Open a console to the server (we only ship billing on production):

`aptible ssh --app geripsy-pro`

`bundle exec rails c`

```ruby
encounters = Enc::Encounter.signed.where(signed_on: (start_date..end_date))
encounters.delete_if { |enc| !enc.billable? } 
encounters.update_all(shipped_hp_billing: nil)
ShipBillingToClaimMdJob.perform_now(encounters.map(&:id))
```

