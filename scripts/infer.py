from pathlib import Path
from frictionless import Resource, Dialect, formats

def infer(dir):
    dir = Path(dir)
    dialect = Dialect()
    dialect.add_control(formats.CsvControl(delimiter='|'))

    for path in dir.glob('*.txt'):
        resource = Resource.describe(path, dialect=dialect)
        resource.format = 'csv'
        resource.infer()
        resource.schema.to_yaml(f'schemas/raw/{path.stem}.yaml')

def main():
    infer('data/raw')

if __name__ == '__main__':
    main()
