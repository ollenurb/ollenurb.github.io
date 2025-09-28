import re
import os
import yaml
import shutil
import logging
import pygments.lexers
import textwrap

from typing import Dict
from pathlib import Path
from posix import listdir
from jinja2 import Environment, FileSystemLoader
from pygments.formatters import HtmlFormatter

# easy logging
logging.basicConfig(
    level=logging.INFO,
    format='%(levelname)s - %(message)s',
    handlers=[logging.StreamHandler()]
)
logger = logging.getLogger(__name__)

# declare assets, too lazy to put them in a separate file
ROOT_DIR = Path("content")
ASSETS = ["css", "img"] # you can add other static assets here
POSTS_DIR = Path("posts")
PAGES_DIR = Path("pages")
OUTPUT_DIR = Path("generated")
METADATA_PATTERN = re.compile(r'\{\#\s*---\s*\n(.*?)\n\s*---\s*\#\}', re.DOTALL)

def highlight(language: str, code: str) -> str:
    """
    Highlight code using pygment
    """
    formatter = HtmlFormatter()
    code = textwrap.dedent(code)
    lex = pygments.lexers.get_lexer_by_name(language)
    res = str(pygments.highlight(code, lex, formatter))
    return res

def extract_post_metadata(post_path: Path) -> Dict[str, str]:
    """
    Given a post, read its metadata block and returns the values as a dictionary
    """
    with open(post_path, 'r') as post_file:
        content = post_file.read()

    meta_match = METADATA_PATTERN.search(content)
    # throw error if block is not found
    if not meta_match: raise Exception("Unable to find metadata block")

    yaml_content = meta_match.group(1)
    metadata = yaml.safe_load(yaml_content)
    return metadata

def main() -> None:
    """Generate the site"""
    env = Environment(loader=FileSystemLoader(ROOT_DIR))
    env.globals["highlight"] = highlight
    # ensure output directories exists
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    os.makedirs(OUTPUT_DIR / POSTS_DIR, exist_ok=True)

    logger.info("Processing posts...")
    # site content will contain tuples with (output_file, template, metadata)
    site_content = []
    for post_path in listdir(ROOT_DIR / POSTS_DIR):
        post_path = POSTS_DIR / post_path
        if post_path.suffix != ".html":
            logger.info(f"Skipping {post_path}, not a valid file")
            continue

        logger.info(f"Found post: {post_path}")
        try:
            post_meta = extract_post_metadata(ROOT_DIR / post_path)
        except Exception as e:
            logger.error(f"Skipping {post_path}, {str(e)}")
            continue

        # collect posts (we need them later to generate the post list)
        post_template = env.get_template(str(post_path))
        site_content.append((post_path, post_template, {"post": post_meta}))

    # needed for blog.html
    posts_metadata = {"posts": [(path, meta["post"]) for path, _, meta in site_content] }

    logger.info("Processing site pages...")
    # include base website pages (index, blog, etc..)
    site_content.extend([
        ("index.html", env.get_template(str(PAGES_DIR / "index.html")), dict()),
        ("blog.html", env.get_template(str(PAGES_DIR / "blog.html")), posts_metadata),
    ])

    logger.info("Moving assets...")
    for asset in ASSETS:
        shutil.copytree(ROOT_DIR / asset, OUTPUT_DIR / asset, dirs_exist_ok=True)
        logger.info(f"Moved: {ROOT_DIR / asset} -> {OUTPUT_DIR / asset}")

    logger.info("Writing files...")
    for output_name, template, context_data in site_content:
        try:
            html_content = template.render(**context_data)
            output_file = OUTPUT_DIR / output_name
            with open(output_file, 'w', encoding="utf-8") as f:
                f.write(html_content.strip())
                logger.info(f"Wrote: {output_file}")
        except Exception as e:
            logger.error(f"Error rendering {output_name}: {str(e)}")
    logger.info("Done!")

if __name__ == "__main__":
    main()
