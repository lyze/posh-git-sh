posh-git-bash
=============

[![Build Status](https://travis-ci.org/lyze/posh-git-sh.svg?branch=master)](https://travis-ci.org/lyze/posh-git-sh)

This script allows you to see the status of the current git repository in your
prompt. It replicates the prompt status from the Windows PowerShell module
[dahlbyk/posh-git](https://github.com/dahlbyk/posh-git).


Installation Instructions
-------------------------
1.  _Optional._ [Install bash-completion](https://github.com/bobthecow/git-flow-completion/wiki/Install-Bash-git-completion).
2.  Copy this file to somewhere (e.g., `~/git-prompt.sh`).
3.  Add the following line to your `~/.bashrc`. (You may need to update
    your `~/.bash_profile` to source your `~/.bashrc`, or you can just modify
   `~/.bash_profile` directly.)

    ```sh
    source ~/git-prompt.sh
    ```

4.  If you are using `bash`, you should call `__posh_git_ps1` in your
    `PROMPT_COMMAND` variable. The function `__posh_git_ps1` takes two
    parameters (`__posh_git_ps1 <prefix> <suffix>`), and sets `PS1` to
    `<prefix><status><suffix>`. You can also use `__posh_git_echo` to echo only
    the status.

    *   Bash example:

    ```bash
    PROMPT_COMMAND='__posh_git_ps1 "\u@\h:\w " "\\\$ ";'$PROMPT_COMMAND
    ```

    This shows username, at-sign, host, colon, cwd, then various status strings,
    followed by dollar and space, as your prompt. This invocation prepends this
    instruction to the existing value of `PROMPT_COMMAND`.

    *   For zsh, you need to set the
    [`PROMPT`](http://zsh.sourceforge.net/Doc/Release/Parameters.html#index-PROMPT)
    variable or the
    [`precmd`](http://zsh.sourceforge.net/Doc/Release/Functions.html#index-precmd)
    hook.

    ```zsh
    precmd() {
      __posh_git_ps1 '\u@\h:\w ' '$ '
    }
    ```

    For some additional hints for integrating with `oh-my-zsh`, take a look at
    [issue #14](https://github.com/lyze/posh-git-sh/issues/14).


The Prompt
----------

By default, the status summary has the following format:

```sh
[{HEAD-name} x +A ~B -C !D | +E ~F -G !H]
```

* `{HEAD-name}` is the current branch, or the SHA of a detached HEAD. The color
  of `{HEAD-name}` represents the divergence from upstream. `{HEAD-name}` also
  changes to indicate progress if you are in the middle of a cherry-pick, a
  merge, a rebase, etc.
  * `cyan`   the branch matches its remote
  * `green`  the branch is ahead of its remote (green light to push)
  * `red`    the branch is behind its remote
  * `yellow` the branch is both ahead of and behind its remote
* `x` is a symbol that represents the divergence from upstream.
  * `≡` the branch matches its remote
  * `↑` the branch is ahead of its remote
  * `↓` the branch is behind its remote
  * `↕` the branch is both ahead of and behind its remote
* Status changes are indicated by prefixes to `A` through `H`, where `A` through
  `D` represent counts for the index and `E` through `H` represent counts for
  the working directory. As in `git status`, index status is dark green and
  working directory status is dark red.
  * `+` added
  * `~` modified
  * `-` removed
  * `!` conflicting

For example, a status of `[master ≡ +0 ~2 -1 | +1 ~1 -0]` corresponds to the
following `git status`:

    # On branch master
    #
    # Changes to be committed:
    #   (use "git reset HEAD <file>..." to unstage)
    #
    #        modified:   this-changed.txt
    #        modified:   this-too.txt
    #        deleted:    gone.txt
    #
    # Changed but not updated:
    #   (use "git add <file>..." to update what will be committed)
    #   (use "git checkout -- <file>..." to discard changes in working directory)
    #
    #        modified:   not-staged.txt
    #
    # Untracked files:
    #   (use "git add <file>..." to include in what will be committed)
    #
    #        new.txt

### Example setup

![Example usage](http://i.imgur.com/nEtBjR2.png)

To get the above prompt display, I have the following in my `.bashrc`:

```sh
export PROMPT_COMMAND='__posh_git_ps1 "\\[\[\e[0;32m\]\u@\h \[\e[0;33m\]\w" " \[\e[1;34m\]\n\$\[\e[0m\] ";'$PROMPT_COMMAND
```

Try it out and let me know what you think!


Configuration Options
---------------------

This script should work out of the box. You can set options controlling the
output of the script by using
[`git config`](https://www.kernel.org/pub/software/scm/git/docs/git-config.html).
This allows you to control the prompt display on a per-repository basis.

For example, if computing file changes is taking too long in a large repository,
you can turn off this behavior (for that repository only):

```sh
cd my-git-repo/
git config bash.enableFileStatus false
```

To restore the default behavior, you can remove the configuration setting:

```sh
cd my-git-repo/
git config --unset bash.enableFileStatus
```

You can also manually edit your git configuration files. These files are most
likely `~/.gitconfig` or `.git/config`. An example illustrating the syntax of
these files can be found at http://git-scm.com/docs/git-config#_example.

### bash.branchBehindAndAheadDisplay

This option controls whether and how to display the number of commits by which
the current branch is behind or ahead of its remote.

*   `full`: _Default_. Display count alongside the appropriate up/down arrow. If
    both behind and ahead, use two separate arrows.
*   `compact`: Display count alongside the appropriate up/down arrow. If both
    behind and ahead, display the behind count, then a double arrow, then the
    ahead count.
*   `minimal`: Display the up/down or double arrow as appropriate, with no
    counts.

### bash.describeStyle

This option controls if you would like to see more information about the
identity of commits checked out as a detached `HEAD`. This is also controlled
by the legacy environment variable `GIT_PS1_DESCRIBESTYLE`.


*  `contains`: relative to newer annotated tag `(v1.6.3.2~35)`
*  `branch`: relative to newer tag or branch `(master~4)`
*  `describe`: relative to older annotated tag `(v1.6.3.1-13-gdd42c2f)`
*  `default`: exactly matching tag

### bash.enableFileStatus

*  `true`: _Default_. The script will query for all file indicators every time.
*  `false`: No file indicators will be displayed. The script will not query
    upstream for differences. Branch color-coding information is still
    displayed.

### bash.enableGitStatus

*  `true`: _Default_. Color coding and indicators will be shown.
*  `false`: The script will not run.

### bash.enableStashStatus

*  `true`: _Default_. An indicator will display if the stash is not empty.
*  `false`: An indicator will not display the stash status.

### bash.showStatusWhenZero

*  `true`:   Indicators will be shown even if there are no updates to the index or
    working tree.
*  `false`: _Default_. No file change indicators will be shown if there are no
   changes to the index or working tree.

### bash.showUpstream

By default, `__posh_git_ps1` will compare `HEAD` to your `SVN` upstream if it can
find one, or `@{upstream}` otherwise. This is also controlled by the legacy
environment variable `GIT_PS1_SHOWUPSTREAM`.

*  `legacy`: Does not use the `--count` option available in recent versions of
   `git-rev-list`
*  `git`: _Default_. Always compares `HEAD` to `@{upstream}`
*  `svn`: Always compares `HEAD` to `SVN` upstream

### bash.enableStatusSymbol

*  `true`: _Default_. Status symbols (`≡` `↑` `↓` `↕`) will be shown.
*  `false`: No status symbol will be shown, saving some prompt length.


Known issues
------------

### Terminal.app

When using Terminal.app, when the prompt is longer than the terminal window
width, the prompt line may not wrap correctly to the next line. This is
suspected to be caused by incorrect handling of ANSI color codes by
Terminal.app. See [issue #18](https://www.github.com/lyze/posh-git-sh/issues/18).


Background
----------

This was my first venture into bash scripting, so I decided to make a clone of
[posh-git](https://github.com/dahlbyk/posh-git), which is a set of PowerShell
scripts for git integration. In my humble opinion, I think it is fantastic.

I based my work off of
https://github.com/git/git/blob/master/contrib/completion/git-prompt.sh

Please do not hesitate to contact me about any issues or requests. I hope that
you may find some use for this script.


License
-------

This is distributed under the GNU GPL v2.0.
