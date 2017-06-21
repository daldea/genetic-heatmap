# Genetic Heatmaps

The genetic heatmaps program is a Unix command-line tool that creates minimally formatted, easy-to-read vector image heatmaps of RNA-seq gene transcription and ChIP gene binding data.

Although many [Gene Set Enrichment Analysis](https://en.wikipedia.org/wiki/Gene_set_enrichment_analysis) programs can also be used to create heatmaps, these heatmaps are typically small raster images that are cluttered with additional graphs and annotations:

<div style="text-align: center"><img src="http://compbio.dfci.harvard.edu/pubs/ovarian_expression/html_results/gsea/gsea_s1.Gsea.1275426366765/enplot_LEADING_EDGE_247.png" title="A poorly designed heatmap made by another program" width="500"/></div>

These heatmaps contain a lot of information, but are not very useful in a publication. In contrast, the heatmaps produced by the genetic heatmaps program:

* are completely free of any built-in annotations
* use easy-to-read color scales that let the data speak for themselves
* can be expanded to any size without losing resolution


<div style="text-align: center"><img src="https://image.ibb.co/e7UUsk/binding.png" title="A gene binding heatmap produced by this program" width="500"/></div>
<div style="text-align: center"><img src="https://image.ibb.co/fCAcCk/transcription.png" title="A gene transcription heatmap produced by this program" width="500"/></div>

## Installation

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
   chmod 755 heatmap terminal-interface.sh heatmap-generator.sh
   ```
5. Move the `heatmap` file to the `~/bin` directory.
   ```
   mv ~/.genetic-heatmaps/heatmap ~/bin
   ```

## Useage

```
heatmap [OPTIONS] CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE BINDING_FILE
```

### Options:

|   Flag   |                Description                |
|   ---    |                    ---                    |
| `-f`     | do not prompt before overwriting files    |
| `-i`     | prompt before overwriting files (default) |
| `-n`     | do not overwrite files                    |
| `--help` | display useage notes                      |

If multiple options are given, only the final option takes effect.

### Arguments:

|       Argument       |                                 Description                                  |
|         ---          |                                     ---                                      |
| `CSV_FILE`           | filepath of the csv file containing gene transcription and gene binding data |
| `LOWER_BOUND`        | minimum value of the gene transcription scale                                |
| `UPPER_BOUND`        | maximum value of the gene transcription scale                                |
| `TRANSCRIPTION_FILE` | filepath where the gene transcription heatmap will be saved                  |
| `BINDING_FILE`       | filepath where the gene binding heatmap will be saved                        |

### Example:
```
heatmap ~/research/data/foo.csv -2.5 2.5 ~/research/figures/bar1.svg ~/research/figures/bar2.svg
```
This command uses the data stored in `~/research/data/foo.csv` to create a gene transcription heatmap located at `~/research/figures/bar1.svg` and a gene binding heatmap located at `~/research/data/bar2.svg`. The gene transcription heatmap is scaled from `-2.5` to `2.5`.

### Making your first heatmap:

1. Use your preferred spreadsheet editor to create a new spreadsheet.
2. Copy-and-paste the gene transcription data into the first column.
3. Copy-and-paste the gene binding data into the second column.
   At this point, your spreadsheet should look like the one below, but with different data.  
   <div style="text-align: center"><img src="https://www.example.com" title="An example spreadsheet" width="500"/></div>


6. Save the spreadsheet as a _comma-separated-values_ (CSV) file.
7. Open a terminal window and type the following command:
   ```
   heatmap CSV_FILE LOWER_BOUND UPPER_BOUND TRANSCRIPTION_FILE BINDING_FILE
   ```  
   Replace `CSV_PATH` with the filepath of the CSV file created in Step 6.  
   Replace `LOWER_BOUND` and `UPPER_BOUND` with the desired minimum and maximum values of the gene transcription scale.  
   Replace `TRANSCRIPTION_PATH` with the filepath where the gene transcription heatmap should be created.  
   Replace `BINDING_PATH` with the filepath where the gene binding heatmap should be created.
8. Check that the gene transcription and gene binding heatmaps were correctly saved to `TRANSCRIPTION_FILE` and `BINDING_FILE`.

## Dependencies

* BASH
* R
* R Libraries:
  * ggplot2
  * svglite

## Legal

Copyright 2017 by [Dennis Aldea](mailto:dennis.aldea@gmail.com).  
Released under the [MIT License](./LICENSE).
