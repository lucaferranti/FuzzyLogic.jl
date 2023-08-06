# Contributor's guide

First of all, huge thanks for your interest in the package! ✨

This page has some tips and guidelines on how to contribute. For more unstructured discussions, you can chat with the developers in the [element chat](https://app.gitter.im/#/room/#FuzzyLogic-jl:gitter.im).

## Discussions

If you are using FuzzyLogic.jl in your work and get stuck, you can use the [helpdesk](https://github.com/lucaferranti/FuzzyLogic.jl/discussions/categories/helpdesk) to ask for help. This is preferable over issues, which are meant for bugs and feature requests, because discussions do not get closed once fixed and remain browsable for others.

There is also a [show and tell](https://github.com/lucaferranti/FuzzyLogic.jl/discussions/categories/show-and-tell) section to share with the world your work using FuzzyLogic.jl. If your work involves a new application of FuzzyLogic.jl and you also want it featured in the Applications section in the documentation, let us know (in the element chat or in an issue). You will get help with the workflow and setup, but you are expected to do the writing 😃 .

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
git clone https://github.com/lucaferranti/FuzzyLogic.jl.git
```
and enter it with

```
cd FuzzyLogic.jl
```

!!! warning "Warning"
    From now on, these instructions assume you are in the `FuzzyLogic.jl` folder

**2.** [Fork the repository](https://github.com/lucaferranti/FuzzyLogic.jl).

**3.** Add your fork as remote with

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
* You can run the tests locally from the Julia REPL with

```julia
include("test/runtests.jl")
```

* Each test file is stand-alone, hence you can also run individual files, e.g. `include("test/test_parser.jl")`

* To make finding tests easier, the test folder structure should (roughly) reflect the structure of the `src` folder.

## Working on the documentation

### Local setup
The first time you start working on the documentation locally, you will need to install all needed dependencies. To do so, run

```
julia docs/setup.jl
```

This needs to be done only the fist time (if you don't have `docs/Manifest.toml`) or any time the Manifest becomes outdated.

Next, you can build the documentation locally by running

```
julia docs/liveserver.jl
```

This will open a preview of the documentation in your browser and watch the documentation source files, meaning the preview will automatically update on every documentation change.

### Working with literate.
* Tutorials and applications are written using [Literate.jl](https://github.com/fredrikekre/Literate.jl). Hence, do not directly edit the markdown files under `docs/src/tutorials` and `docs/src/applications`, edit instead the corresponding julia files under `docs/src/literate`. 

## Further reading

Here is a list of useful resources for contributors.

* [Making a first Julia pull request](https://kshyatt.github.io/post/firstjuliapr/) <-- read this if you are not familiar with the git workflow!
* [JuliaReach developers docs](https://github.com/JuliaReach/JuliaReachDevDocs)
* [Julia contributing guideline](https://github.com/JuliaLang/julia/blob/master/CONTRIBUTING.md)
