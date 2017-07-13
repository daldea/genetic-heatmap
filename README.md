# Genetic Heatmap Tools

Genetic Heatmap Tools is a program that creates easy-to-read heatmaps of gene transcription and transcription factor binding data. These heatmaps are a visually attractive method of communicating how transcription factor binding affects gene expression.

Although many [Gene Set Enrichment Analysis](https://en.wikipedia.org/wiki/Gene_set_enrichment_analysis) programs can also be used to create similar heatmaps, those heatmaps are typically cluttered with additional graphs and annotations, rendering them ill-suited for publication:

<img src="https://image.ibb.co/iWpt7v/gsea.png" title="A poorly designed heatmap made by another program" width="500"/>

In contrast, the heatmaps produced by the genetic heatmaps program:

* are completely free of distracting annotations
* use easy-to-read color scales that clearly display the data
* can be expanded to any size without losing resolution

<img src="https://image.ibb.co/ei52Za/b.png" title="A gene binding heatmap produced by this program" width="500"/>
<img src="https://image.ibb.co/dH91Sv/t.png" title="A gene transcription heatmap produced by this program" width="500"/>

## Installation

### Automatic Installation

1. [Download](https://raw.githubusercontent.com/dennisaldea/genetic-heatmaps/analysis/installer.sh) the installer.
   ```
   cd ~/Downloads
   wget https://raw.githubusercontent.com/dennisaldea/genetic-heatmaps/analysis/installer.sh
   ```

2. Run the installer.
   ```
   ./installer.sh
   ```

The installer only installs Genetic Heatmap Tools for the user running the script. To install Genetic Heatmap Tools for all users, modify the steps listed in the [Manual Installation](#manual-installation) section.

### Manual Installation

1. [Download](https://github.com/dennisaldea/genetic-heatmaps/archive/master.tar.gz) the repository.
   ```
   cd ~/Downloads
   wget https://github.com/dennisaldea/genetic-heatmaps/archive/master.tar.gz
   ```

2. Extract the TAR archive.
   ```
   tar -xzvf master.tar.gz
   rm master.tar.gz
   ```

3. Move the extracted files to the `~/.genetic-heatmaps` directory.
   ```
   mkdir ~/.genetic-heatmaps
   mv -T genetic-heatmaps-master ~/.genetic-heatmaps
   ```

4. Mark the code files as executable.
   ```
   cd ~/.genetic-heatmaps
   chmod 755 *
   chmod 644 README.md LICENSE HELP/*
   ```

5. Copy the alias file to the `~/bin` directory.
   ```
   cp ~/.genetic-heatmaps/ghmtools ~/bin
   ```

## Usage

Genetic Heatmap Tools has three operations, which are described in the table below.

| Operation  |                                    Description                                    |
|    ---     |                                        ---                                        |
| `analysis` | create gene activity files from RNA-seq data, ChIP-seq data, and bound gene lists |
| `heatmap`  | create gene transcription and gene binding heatmaps from gene activity files      |
| `help`     | display the usage notes for a specified operation                                 |

Typical procedure:

1. Input RNA-seq data and either ChIP-seq data or a list of bound genes into the `analysis` operation.
2. Confirm that the resulting gene activity file was properly created.
3. Input the gene activity file into the `heatmap` operation.

### Analysis

```
ghmtools analysis [OPTIONS] TRANSCRIPTION_DATA BINDING_DATA GENOME GENE_FILE
```

#### Options

|     Option       |                                            Description                                            |
|       ---        |                                                ---                                                |
| `-f`             | do not prompt before overwriting files                                                            |
| `-i`             | prompt before overwriting files _(default)_                                                       |
| `-n`             | do not overwrite files                                                                            |
| `-d <NUMBER>`    | maximum distance (in kilobases) between a bound gene and the nearest binding site _(default: 10)_ |
| `--window <INT>` | number of genes to be summed to calculate a binding score _(default: 10)_                         |

If neither `-f`, `-i`, nor `-n` are given, the `-i` option is implied.  
If conflicting options are given, the last option given takes effect.

#### Arguments

|      Argument        |                              Description                               |
|         ---          |                                  ---                                   |
| `TRANSCRIPTION_DATA` | filepath of the file containing gene transcription scores              |
| `BINDING_DATA`       | filepath of the file containing ChIP-seq data or a list of bound genes |
| `GENOME`             | reference genome used by BETA _(options: hg19, mm9)_                   |
| `GENE_FILE`          | filepath where the gene activity file will be saved                    |

It is not necessary to specify whether `BINDING_DATA` is a ChIP-seq data file or a list of bound genes, since the analysis interface can determine this automatically.

#### Example

```
ghmtools analysis foo1.csv foo2.svg mm9 bar.csv
```

* use the gene transcription data at `foo1.csv`
* use the gene binding data at `foo2.csv`
  * create a list of bound genes using the `mm9` genome
* create a gene activity file at `bar.csv`

### Heatmap

```
ghmtools heatmap [OPTIONS] GENE_DATA TRANSCRIPTION_MIN TRANSCRIPTION_MAX [BINDING_MAX] TRANSCRIPTION_FILE BINDING_FILE
```

#### Options

|   Option    |                   Description                   |
|     ---     |                       ---                       |
| `-f`        | do not prompt before overwriting files          |
| `-i`        | prompt before overwriting files _(default)_     |
| `-n`        | do not overwrite files                          |
| `--nozeros` | do not map genes with zero transcription values |

If neither `-f`, `-i`, nor `-n` are given, the `-i` option is implied.  
If conflicting options are given, the last option given takes effect.

#### Arguments

|      Argument        |                                   Description                                    |
|         ---          |                                       ---                                        |
| `GENE_DATA`          | filepath of the file containing gene transcription and gene binding data         |
| `TRANSCRIPTION_MIN`  | minimum value on the gene transcription scale                                    |
| `TRANSCRIPTION_MAX`  | maximum value on the gene transcription scale                                    |
| `BINDING_MAX`        | maximum value on the gene binding scale _(optional)_                             |
| `TRANSCRIPTION_FILE` | filepath where the gene transcription heatmap will be saved                      |
| `BINDING_FILE`       | filepath where the gene binding heatmap will be saved                            |

If `BINDING_MAX` is not given or is set to `NONE`, the maximum value on the gene binding scale is set to the maximum gene binding value in the data.

#### Example

```
ghmtools heatmap foo.csv -2.5 2.5 6 bar1.svg bar2.png
```

* use the data at `foo.csv`
* create a gene transcription heatmap at `bar1.svg`
  * scale the transcription scores from `-2.5` to `2.5`
* create a gene binding heatmap at `bar2.png`
  * scale the binding scores from 0 to `6`

### Help

```
ghmtools help <OPERATION>
```

```
ghmtools --help <OPERATION>
```

If no operation is given, `ghmtools help` displays a list of operations.

## Dependencies

* BASH
* Python 3
* [BETA](http://cistrome.org/BETA/)
* R
  * ggplot2
  * svglite

## Legal

Copyright 2017 by [Dennis Aldea](mailto:dennis.aldea@gmail.com).  
Released under the [MIT License](./LICENSE).
