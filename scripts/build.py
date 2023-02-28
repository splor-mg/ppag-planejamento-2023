import argparse
from pathlib import Path
from frictionless import Package
import subprocess

def get_git_revision_hash():
    return subprocess.check_output(['git', 'rev-parse', 'HEAD']).decode('ascii').strip()

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('input')
    parser.add_argument('output')
    args = parser.parse_args()
    
    package = Package.from_descriptor(args.input)
    commit = get_git_revision_hash()
    package.custom['commit'] = commit
    for resource in package.resources:
        resource.infer(stats=True)

    Path(args.output).parent.mkdir(exist_ok=True)
    package.publish(args.output)
    
if __name__ == '__main__':
    main()
