  #!/bin/bash
  
    TOKEN="1235565537:AAFc82-ZZKrtLxA2uttTCewWd6pDd2oMVHg"
    ID="576786484"
    URL="https://api.telegram.org/bot$TOKEN/sendMessage"
  
    # Exit immediately if a pipeline returns a non-zero status.
    set -e
    
    curl -s -X POST $URL -d chat_id=$ID -d text="🚀 Iniciando deployment en jlykos.github.io"
    echo "🚀 Iniciando deployment"

    # Here we are using the variables
    # - GITHUB_ACTOR: It is already made available for us by Github. It is the username of whom triggered the action
    # - GITHUB_TOKEN: That one was intentionally injected by us in our workflow file.
    # Creating the repository URL in this way will allow us to `git push` without providing a password
    # All thanks to the GITHUB_TOKEN that will grant us access to the repository
    REMOTE_REPO="https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/${GITHUB_REPOSITORY}.git"

    # We need to clone the repo here.
    # Remember, our Docker container is practically pristine at this point
    git clone $REMOTE_REPO repo
    cd repo

    # Install all of our dependencies inside the container
    # based on the git repository Gemfile
    
    curl -s -X POST $URL -d chat_id=$ID -d text="⚡️ Instalando dependencias del proyecto."
    echo "⚡️ Instalando dependencias del proyecto..."
    bundle update
    bundle install

    # Build the website using Jekyll
    curl -s -X POST $URL -d chat_id=$ID -d text="🏋️ Construyendo website."
    echo "🏋️ Construyendo website..."
    JEKYLL_ENV=production bundle exec jekyll build --trace
    echo "Jekyll build completo"

    # Now lets go to the generated folder by Jekyll
    # and perform everything else from there
    cd _site

    curl -s -X POST $URL -d chat_id=$ID -d text="☁️ Publicando website."
    echo "☁️ Publicando website"

    # We don't need the README.md file on this branch
    rm -f README.md

    # Now we init a new git repository inside _site
    # So we can perform a commit
    git init
    git config user.name "${GITHUB_ACTOR}"
    git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
    git add .
    # That will create a nice commit message with something like:
    # Github Actions - Fri Sep 6 12:32:22 UTC 2019
    git commit -m "Github Actions - $(date)"
    echo "Build branch ready to go. Pushing to Github..."
    # Force push this update to our gh-pages
    git push --force $REMOTE_REPO master:gh-pages
    # Now everything is ready.
    # Lets just be a good citizen and clean-up after ourselves
    rm -fr .git
    cd ..
    rm -rf repo
    curl -s -X POST $URL -d chat_id=$ID -d text="🎉 Version actualizada 🎊"
    echo "🎉 Nueva version deployed 🎊"
