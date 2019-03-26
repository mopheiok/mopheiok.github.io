hexo clean
hexo g
# generate resume
php ~/github/markdown-resume/bin/md2resume html --template swissen ~/github/markdown-resume/resume/resume_public.md ~/github/markdown-resume/resume/
cp ~/github/markdown-resume/resume/resume_public.html ./public/about/index.html

gulp

hexo d
