---
title: Portuguese inspection terminology
domain: technical-inspection
feature: inspection-event
status: active
owners: [Developer, Tester, Documenter]
source_files:
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/Common/Localization/InspectionLocalization.swift
  - FSAECertification/FSAEInspectionChecklist/FSAEInspectionChecklist/pt-BR.lproj/Localizable.strings
related_scenarios: [Display strings use localizable structured constants, Session selector identifiers]
---

# Portuguese inspection content

On iOS, choose Português (Brasil) or English in Settings → Apps → FSAEInspectionChecklist → Language. The globe button on the Inspections screen opens the app's Settings page. The app uses the system-selected bundle localization for interface strings and inspection content. iOS relaunches the app when the app's language changes.

`InspectionLocalization` uses the native `pt-BR.lproj/Localizable.strings` bundle. English source strings are the lookup keys and fallback. Per-view `Strings` namespaces resolve at rendering time. All six bundled stage titles, sections, item titles and instructions have Portuguese translations. Generated step titles are translated only for display. Test details expose the original English instruction and a terminology reference.

The English JSON remains the inspection content source. Translations never rewrite stage/section/test/step IDs, rule references, badges, outcome raw values, measurements, judge notes, attachments or snapshots. Keep the English energized badge literal in JSON decoding; decoding must not depend on the selected display language.

## Terminology references

These publications support terminology, not a claim that this app is an official Portuguese rulebook. The translation follows the bundled sheet's edition and values; it does not upgrade the rules to another year.

- [SAE BRASIL, Guia de Procedimentos na Inspeção Técnica FSAE-B 2024](https://arquivos.saebrasil.org.br/2024/Formula/Informativo23-GuiadeProcedimentosnaInspecaoTecnicaFSAE-B2024.pdf): inspection workflow, equipment inspection, bodywork, accumulator, seals and driver exit.
- [SAE BRASIL, Adendo de Regulamento FSAEB 2024, version 3](https://arquivos.saebrasil.org.br/2024/Formula/FSAEB_2024_Adendo_Regulamento_V3.pdf): electrical inspection, PPE, accumulator cells, measurement probes and driver exit.

| Source term | Portuguese display |
| --- | --- |
| Garage Inspection | Inspeção de equipamentos |
| Body Inspection | Inspeção de carenagem |
| Chassis Inspection | Inspeção de chassi |
| EV Inspection | Inspeção elétrica (EV) |
| Egress Test | Teste de saída do piloto |
| Rain Test | Teste de chuva |
| Accumulator | Acumulador |
| Firewall | Parede corta-fogo (firewall) |
| Tractive System | Sistema trativo (TS) |
| Shutdown circuit | Circuito de desligamento |
| Interlock | Intertravamento |
| Arm restraints | Restritores de braço |

Keep official acronyms (IMD, AMS/BMS, ESF, SES, TSMS, GLVMS, TSMP, MSD, BSPD, APPS, RML/RTML and TSSI) as written in each source item. Do not silently merge similar acronyms or replace required equipment markings. English marking text such as “High Voltage Present” stays quoted with a Portuguese explanation.

## Validation and maintenance

`InspectionLocalizationTests` checks translation coverage across the six bundled stages, unchanged numeric tokens in every instruction, English fallback, language resolution and representative terminology. Existing domain tests cover identity, badge decoding, draft isolation and submission. Numeric preservation does not establish semantic correctness; review changed instructions against the source sheet and the references above.

When the source changes, update the exact English lookup key and its Portuguese translation together. Never translate IDs or user-entered content. Inspect long instructions and result controls in Portuguese on a compact screen. Hardware installation and inspection procedure validation require separate evidence.
