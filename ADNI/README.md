
# ADNI

Conversion scripts written by M. Stritt, 2021.

## xASL_adni_ValidateDatasets.m

Script to compare the downloaded ADNI archive with its corresponding label file. Helpful to validate if all cases have been downloaded.

## xASL_adni_Convert2Source.m

Script to convert ADNI cases to cases with a source structure. These can be converted to ASL-BIDS using ExploreASL.

## xASL_adni_Convert2BIDS.m

Script to convert the cases in source structure to ASL-BIDS using ExploreASL.

## userConfig.json

Short example:

```json
{
	"ADNI_VERSION": 2,	
	"ADNI_ORIGINAL_DIR": "path\\ADNI\\test_in",
	"ADNI_OUTPUT_DIR": "path\\ADNI\\test_out"
}
```



