+++
title = "First Post"
date = "2024-03-29T13:41:11-03:00"
+++

So I decided to start a blog.. and fell into the usual trap of allowing perfect to be the enemy of good, and went down a rabbit hole of "Which Blog Software To Use?".

I had used `Hugo` in the long-distant past to host a website for my (now defunct) Limited Company back in the day, but as I never posted anything on it after setting it up I feared that if I used something non-obvious and self-hosted I would not post.

So I looked at Wordpress's free hosted options, signed up, but then never posted there either.

Then today I got the impetetus to give it another go, went into my `~/git/` directory and was surprised to find the unfinished sandwich.

```shell
~/git$ cd hugoblog/
~/git/hugoblog (main +%=)$ git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        new file:   .gitmodules
        new file:   themes/ananke

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        .DS_Store
        .hugo_build.lock
        archetypes/
        content/
        hugo.toml
        resources/

~/git/hugoblog (main +%=)$ git remote -v
origin  git@github.com:mackenzie-remote/hugoblog.git (fetch)
origin  git@github.com:mackenzie-remote/hugoblog.git (push)
```

and the `first-post.md` had a date of `date: 2023-06-29T13:57:28-03:00`.

I was going to backdate the post, but that seems silly. I'm doing it 9 months later :D