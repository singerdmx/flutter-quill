# Contributing

The contributions are more than welcome! <br>
This project will be better with the open-source community help

You can check the [Todo](./doc/todo.md) list if you want to

There are no guidelines for now.
This page will be updated in the future.

## Steps to contributing

You will need a GitHub account as well as Git installed and configured with your GitHub account on your machine

1. Fork the repository in GitHub
2. clone the forked repository using `git`
3. Add the `upstream` repository using:
    ```
    git remote add upstream git@github.com:singerdmx/flutter-quill.git
    ```
4. Open the project with your favorite IDE, usually, we prefer to use Jetbrains IDEs, but since [VS Code](https://code.visualstudio.com) is more used and has more support for Dart, then we suggest using it if you want to.
5. Create a new git branch and switch to it using:
   
    ```
    git checkout -b your-branch-name
    ```
    The `your-branch-name` is your choice
6. Make your changes
7. If you are working on changes that depend on different libraries in the same repo, then in that directory copy `pubspec_overrides.yaml.disabled` which exists in all the libraries (`flutter_quill_test` and `flutter_quill_extensions` etc...)
to `pubspec_overrides.yaml` which will be ignored by `.gitignore` and will be used by dart pub to override the libraries
    ```
    cp pubspec_overrides.yaml.disabled pubspec_overrides.yaml
    ```
    or save some time with the following script:
    ```
    ./scripts/enable_local_dev.sh
    ```
8. Test them in the [example](./example) and add changes in there if necessary
9.  Run the following script if possible
    ```
    ./scripts/before_push.sh
    ```
10. When you are done sending your pull request, run:
    ```
    git add .
    git commit -m "Your commit message"
    git push origin your-branch-name
    ```
    this will push the new branch to your forked repository

11. Now you can send your pull request either by following the link that you will get in the command line or open your
forked repository. You will find an option to send the pull request, you can also
open the [Pull Requests](https://github.com/singerdmx/flutter-quill) tab and send new pull request

12.   Please wait for the review, and we might ask you to make more changes, then run:
```
git add .
git commit -m "Your new commit message"
git push origin your-branch-name
```

Thank you for your time and efforts in this open-source community project!!

## Development Notes
Please read the [Development Notes](./doc/development_notes.md) as they are important while development