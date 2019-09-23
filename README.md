# [kean.github.io](https://kean.github.io)

A personal homepage and blog.

## How this works

This is a static site built using [Jekyll](https://jekyllrb.com) and hosted on [Github Pages](https://pages.github.com).

- `index.md`: The landing page of [kean.github.io](https://kean.github.io)
- `_posts/`: The directory containing all the shared posts

The code (tries to) follows [BEM methodology](https://en.bem.info/methodology/), but with a custom naming convension which should be more familiar for native developers.

## How to contribute

To run the server locally:

- `git clone https://github.com/kean/kean.github.io`
- `bundle install`
- `bundle exec jekyll serve`
- Open [http://127.0.0.1:4000](http://127.0.0.1:4000)

## Deployment

This page is automatically deployed on each push into `master` branch.

Unfortunately, GitHub Pages doesn't support Semantic Indexing (`--lsi`), so it will have to be run locally before deployment by running `./_sciprts/generate_related_posts.rb`.

## License

There are many blogs but this one is mine.
