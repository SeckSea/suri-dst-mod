# suri-dst-mod

Welcome to our silly little modding project that we're making for VnU Gen 3 Oracle!

## Getting Started:

1. Ensure you have Git installed on your computer
    - Navigate to https://www.git-scm.com/ and download for your respective OS.
    - You can check to see if you've successfully installed to your system by opening your terminal/command prompt and run the command:
    
    git version

2. Clone the Repository
    - Navigate to the dropdown button labelled "Code" and copy the link.
    - Open the folder you will be working from in your terminal and run the command:

    git clone [insert copied link here]

    - The repository should be cloned to your local.

## Working in the Project:

1. Create your own branch
    - You will be working in your own branch so as not to interfere with other developers!
    - Ensure you are currently in the main branch. Run the following to move to the main branch if you are not:

    git checkout main

    - Create your branch by running:

    git checkout -b [name of branch] (Using your username as the name is perfectly fine)

2. Push your changes from your local branch to the remote repository
    - After you've made your changes locally, you can push to your branch in the remote repository.
    - Run the following commands:

    git add . 

    git commit -m "Commit message"  (the quotations are necessary)

    git push

    - N.B. This will not affect the main branch as long as you are working in your branch so no worries when doing this!

3. Update your local repository
    - As others will be working on the project simultaneously, you may want to occasionally update your local repository that others have uploaded to the main branch
    - Navigate to your local main branch. Run the following:

    git checkout main

    - Update your local main:

    git pull

    - Update your branch now:

    git checkout [name of your branch]
    git merge main

    - N.B. You may get some merge conflicts. Feel free to resolve them yourself or ask questions in the discord if you aren't sure! (Ping @SeckSea or @MottledAbyss)

## Rules of Thumb:

1. Try not to interfere with others' branches, especially without permission! Keep your changes to your own branch!

2. When pushing, you will be prompted to make a Pull Request (PR) if you want to merge your changes to main branch. Feel free to make the PR but notify either @SeckSea or @MottledAbyss in the discord to approve as we are leading the development and we wanna make sure nothing breaks lol

3. Don't feel pressured to dedicate your time to this project and don't worry if you get stuck! If at any point you want to stop working with the project, feel free and let us know!

4. Have fun with it!! (coding... pain) And thank you again so much for the help! 