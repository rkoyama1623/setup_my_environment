# dot.emacs.d
## What is this?
This directory is used for emacs setting.

## How to use?
Plase run following commands.

```bash
ln -s /path/to/dot.emacs.d ~/.emacs.d
```

After that, launch emacs!
Download will begin.

# How to configure?
Emacs loads `init.el` at first.
Then, `init.el` loads files in `init` directory.

## Trouble Shooting
### Elget Cannot Download the Target!
Plase check `el-get.lock` file.  
Your target maybe obsolete.  
The version of your target is specified in `el-get.lock`.
