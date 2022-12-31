# Contributor's guide

First of all, huge thanks for your interest in the package! ✨

This page has some tips and guidelines on how to contribute.

## Opening issues

If you spot something strange in the software (something doesn't work or doesn't behave as expected) do not hesitate to open a [bug issue](https://github.com/lucaferranti/FuzzyLogic.jl/issues/new?assignees=&labels=bug&template=bug_report.md&title=%5Bbug%5D).

If have an idea of how to make the package better (a new feature, a new piece of documentation, an idea to improve some existing feature), you can open an [enhancement issue](https://github.com/lucaferranti/FuzzyLogic.jl/issues/new?assignees=&labels=enhancement&template=feature_request.md&title=%5Benhancement%5D%3A+). 

In both cases, try to follow the template, but do not worry if you don't know how to fill something. 

If you feel like your issue does not fit any of the above mentioned templates (e.g. you just want to ask something), you can also open a [blank issue](https://github.com/lucaferranti/FuzzyLogic.jl/issues/new).

## Collaborative Practices

We follow the [ColPrac guide for collaborative practices](https://github.com/SciML/ColPrac). New contributors should make sure to read that guide. Below are some additional practices we follow.

## Git workflow

All contributions should go through git branches. If you are not familiar with git practices, you will find some references at the end of this file. Here is a short cheat-sheet.

### Setup

**1.** Clone the repository

```
git clone 
```

**2.** [Fork the repository](https://github.com/lucaferranti/FuzzyLogic.jl).

**3.** Add your for as remote with

```
git remote add $new_remote_name $your_fork_link
```

for example

```
git remote add johndoe https://github.com/johndoe/FuzzyLogic.jl.git
```

after this running `git remote -v` should produce

```
lucaferranti  https://github.com/lucaferranti/FuzzyLogic.jl.git (fetch)
lucaferranti  https://github.com/lucaferranti/FuzzyLogic.jl.git (push)
johndoe        https://github.com/johndoe/FuzzyLogic.jl.git (fetch)
johndoe       https://github.com/johndoe/FuzzyLogic.jl.git (push)
```

### Working with branches

**0.** Run `git branch` and check you are on `main`. If you are not, switch to `main` via

```
git switch main
```

Next, make sure your local version is up to date by running

```
git fetch origin
git merge origin/main
```

**1.** Create a new branch with

```
git switch -c $new-branch-name
```


**3.** Now let the fun begin! Fix bugs, add the new features, modify the docs, whatever you do, it's gonna be awesome!

**4.** When you are ready, go to the [package main repository](https://github.com/lucaferranti/FuzzyLogic.jl) (not your fork!) and open a pull request.

**5.** If nothing happens within 7 working days feel free to ping Luca Ferranti (@lucaferranti) every 1-2 days until you get his attention.

## Coding guideline

* The package follows [SciMLStyle](https://github.com/sciml/SciMLStyle).

## Further reading

Here is a list of useful resources for contributors.

* [Making a first Julia pull request](https://kshyatt.github.io/post/firstjuliapr/) <-- read this if you are not familiar with the git workflow!
* [JuliaReach developers docs](https://github.com/JuliaReach/JuliaReachDevDocs)
* [Julia contributing guideline](https://github.com/JuliaLang/julia/blob/master/CONTRIBUTING.md)
