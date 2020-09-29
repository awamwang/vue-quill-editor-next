#!/bin/bash
version_pattern='^v?\d+\.\d+\.\d+$'
publish_pattern='npm publish$'

setup_git() {
  local name
  local email

  git config --global user.email ${email}
  git config --global user.name ${name}
}

commit_website_files() {
  echo "Committing to master branch..."
  git checkout master
  git add .

  if [ $TRAVIS_EVENT_TYPE == "cron" ]; then
    git commit --message "Travis build: $TRAVIS_BUILD_NUMBER [cron]"
  elif [ $TRAVIS_EVENT_TYPE == "api" ]; then
    git commit --message "Travis build: $TRAVIS_BUILD_NUMBER [custom]"
  else
    git commit --message "Travis build: $TRAVIS_BUILD_NUMBER"
  fi
}

upload_files() {
  echo "Pushing to master branch..."
  local repo_name = cat package.json| jq '.name'
  git push --force --quiet "https://${GH_TOKEN}@github.com/awamwang/${repo_name}.git" master > /dev/null 2>&1
}

npm_publish() {
  if [[ $TRAVIS_COMMIT_MESSAGE =~ $version_pattern ] || [ $TRAVIS_COMMIT_MESSAGE =~ $publish_pattern ]]; then
    echo "Npm publish ${TRAVIS_COMMIT_MESSAGE}..."
    npm publish
  fi
}

setup_git
commit_website_files
upload_files
# npm_publish
