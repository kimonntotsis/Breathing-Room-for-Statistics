# Chapter 18 Solutions

**E18.1** Visits from the same patient are correlated; treating them as independent inflates precision.

**E18.2** Each patient has their own baseline FEV1 level around which visits vary.

**Applied** Positive `weeks:groupintervention` suggests higher FEV1 trajectory on intervention (synthetic data). Week-52-only model has smaller SE but wrong unit of inference.

**E18.3** It ignores correlated visits and baseline trajectory information.
