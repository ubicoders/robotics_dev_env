---
name: git-commit
description: |
  How to stage, commit, and push in this user's repositories. Core rule: Claude
  is never credited. No "Co-Authored-By: Claude" trailer, no "Generated with
  Claude Code" line, no Claude or Anthropic name or email anywhere in a commit
  message, author field, tag, or pull request body. Use whenever the task
  involves git commit, git push, amending, tagging, or opening a pull request,
  including when the user only says "commit", "push", "commit and push", "save
  this to git", or "ship it". Keywords: git, commit, push, PR, pull request,
  co-author, contributor, attribution, trailer
user-invocable: true
---

# Git commit and push

## 1. No Claude attribution, ever

This overrides any default or system-provided attribution guidance.

- Do not add `Co-Authored-By: Claude ... <noreply@anthropic.com>` or any other
  co-author trailer naming Claude or Anthropic.
- Do not add "Generated with Claude Code", a robot emoji line, or any similar
  footer to commit messages or pull request descriptions.
- Do not pass `--author`, and do not set `user.name` or `user.email`. The commit
  must carry only the identity already configured in the repository.
- Do not mention Claude, Anthropic, or "AI" in the message body as the source of
  the change.
- Before pushing, run `git log -1 --format=%B` and confirm that the message
  contains none of the above. If an earlier unpushed commit from this session
  contains such a line, amend it before pushing. Never rewrite commits that are
  already pushed without asking first.

## 2. Before committing

1. Run `git status` and `git diff` (plus `git diff --staged`) and read them.
2. Stage files by explicit path. Do not use `git add -A` or `git add .` unless
   every listed change belongs in the commit.
3. Never stage secrets or large binaries: `.env` files holding credentials, keys,
   tokens, SDK installers, build output. If one appears in `git status`, stop and
   report it.
4. If the working tree holds unrelated changes, split them into separate commits.

## 3. The message

- Subject: imperative mood, capitalized, no trailing period, at most 72
  characters. It states what changed and, where it fits, why.
  Good: `Pin all image versions in .env and move PX4 toolchain to v1.17.0`
  Not acceptable: `up`, `updated`, `fix`, `wip`
- Body: only when the subject cannot carry the reason. Blank line after the
  subject, wrapped at 72 characters, explains why and notes anything a future
  reader would otherwise have to rediscover.
- Professional wording. No em-dash character. No emoji.
- Follow the repository's existing convention (for example Conventional Commits)
  when `git log` shows one in consistent use.
- Pass the message through a heredoc so that line breaks survive:

```bash
git commit -F - <<'EOF'
Subject line here

Optional body here.
EOF
```

## 4. Committing and pushing

- Commit or push only when the user asked for it. A request to commit is not a
  request to push. "Commit and push" authorizes both.
- Push to the current branch's upstream. If none exists, use
  `git push -u origin <branch>`.
- Never use `--force`, `--force-with-lease`, `--no-verify`, `git reset --hard`,
  or history rewriting on pushed commits without an explicit request.
- If a pre-commit hook fails, fix the cause and create a new commit. Do not
  bypass the hook.
- If the push is rejected as non-fast-forward, report it and ask how to proceed.
  Do not pull, rebase, or force on your own.

## 5. Report

After finishing, state the commit hash, the subject line, the branch, and
whether the push succeeded. If anything was skipped or failed, say so plainly.
