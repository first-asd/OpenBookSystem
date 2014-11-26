#!/bin/sh

Local Maven Local Repository: /Users/Eduard/.m2/repository/ 



#The Production endpoints moved from UJ to UW. Here are the clients for these moved web services.

mvn install:install-file -Dfile=DisambiguationAgainstWikipedia-UJ-UW-Production.jar -DgroupId=openbook-uj -DartifactId=DisambiguationAgainstWikipedia-ujuw-production -Dversion=0.1.0 -Dpackaging=jar

mvn install:install-file -Dfile=OfflineImageRetrieval-UJ-UW-Production.jar -DgroupId=openbook-uj -DartifactId=OfflineImageRetrieval-ujuw-production -Dversion=0.1.0 -Dpackaging=jar

mvn install:install-file -Dfile=MultiWordDetection-UJ-UW-Production.jar -DgroupId=openbook-uj -DartifactId=MultiWordDetection-ujuw-production -Dversion=0.1.0 -Dpackaging=jar


mvn install:install-file -Dfile=Summarizer-UJ-UW-Production.jar -DgroupId=openbook-uj -DartifactId=Summarizer-ujuw-production -Dversion=0.1.0 -Dpackaging=jar

mvn install:install-file -Dfile=SyntacticSimplification-UJ-UW-Production.jar -DgroupId=openbook-uj -DartifactId=SyntacticSimplification-ujuw-production -Dversion=0.1.0 -Dpackaging=jar



Production Web Services:

1. mvn install:install-file -Dfile=Coreference-UA-Spanish-Production.jar -DgroupId=openbook-ua -DartifactId=CoreferenceSpanish-production -Dversion=0.1.0 -Dpackaging=jar

2. mvn install:install-file -Dfile=Coreference-UW-Bulgarian-Production.jar -DgroupId=openbook-uw -DartifactId=MultiWordDetectionCoreferenceBulgarian-production -Dversion=0.1.0 -Dpackaging=jar

3. mvn install:install-file -Dfile=Coreference-UW-English-Production.jar -DgroupId=openbook-uw -DartifactId=CoreferenceEnglish-production -Dversion=0.1.0 -Dpackaging=jar


4. mvn install:install-file -Dfile=Disambiguation-UA-Production.jar -DgroupId=openbook-ua -DartifactId=Disambiguation-production -Dversion=0.1.0 -Dpackaging=jar



9. mvn install:install-file -Dfile=Syntax-UW-English-Production.jar -DgroupId=openbook-uw -DartifactId=Syntax-production -Dversion=0.1.0 -Dpackaging=jar

10. mvn install:install-file -Dfile=EssentialProcessing-UW-Bulgarian-Production.jar -DgroupId=openbook-uw -DartifactId=EssentialProcessing-production -Dversion=0.1.0 -Dpackaging=jar


12. mvn install:install-file -Dfile=MultiWordDetection-UA-Production.jar -DgroupId=openbook-ua -DartifactId=MultiWordDetection-UA-production -Dversion=0.1.0 -Dpackaging=jar

13. mvn install:install-file -Dfile=SyntacticSimplification-UA-Spanish-Production.jar -DgroupId=openbook-ua -DartifactId=SyntacticSimplification-UA-production -Dversion=0.1.0 -Dpackaging=jar

14. mvn install:install-file -Dfile=Acronyms-UA-Production.jar -DgroupId=openbook-ua -DartifactId=Acronyms-UA-Production -Dversion=0.1.0 -Dpackaging=jar



Development Web Services:

1. mvn install:install-file -Dfile=Coreference-UA-Spanish-Development.jar -DgroupId=openbook-ua -DartifactId=CoreferenceSpanish-development -Dversion=0.1.0 -Dpackaging=jar

2. mvn install:install-file -Dfile=Coreference-UW-Bulgarian-Development.jar -DgroupId=openbook-uw -DartifactId=CoreferenceBulgarian-development -Dversion=0.1.0 -Dpackaging=jar

3. mvn install:install-file -Dfile=Coreference-UW-English-Development.jar -DgroupId=openbook-uw -DartifactId=CoreferenceEnglish-development -Dversion=0.1.0 -Dpackaging=jar

4. mvn install:install-file -Dfile=Diambiguation-UA-Development.jar -DgroupId=openbook-ua -DartifactId=Disambiguation-development -Dversion=0.1.0 -Dpackaging=jar


5. mvn install:install-file -Dfile=EssentialProcessing-UW-Bulgarian-Development.jar -DgroupId=openbook-uw -DartifactId=EssentialProcessing-development -Dversion=0.1.0 -Dpackaging=jar

6. mvn install:install-file -Dfile=MultiWordDetection-UA-Development.jar -DgroupId=openbook-ua -DartifactId=MultiWordDetection-UA-development -Dversion=0.1.0 -Dpackaging=jar

7. mvn install:install-file -Dfile=SyntacticSimplification-UA-Spanish-Development.jar -DgroupId=openbook-ua -DartifactId=SyntacticSimplification-UA-development -Dversion=0.1.0 -Dpackaging=jar

8. mvn install:install-file -Dfile=SyntacticSimplification-UJ-Spanish-Production.jar -DgroupId=openbook-uj -DartifactId=SyntacticSimplification-UJ-production -Dversion=0.1.0 -Dpackaging=jar

9. mvn install:install-file -Dfile=MultiWordDetection-UJ-Spanish-Development.jar -DgroupId=openbook-uj -DartifactId=MultiWordDetection-UJ-development -Dversion=0.1.0 -Dpackaging=jar

10.  mvn install:install-file -Dfile=Syntax-UW-English-Development.jar -DgroupId=openbook-uw -DartifactId=Syntax-UW-development -Dversion=0.1.0 -Dpackaging=jar

11. mvn install:install-file -Dfile=Acronyms-UA-Development.jar -DgroupId=openbook-ua -DartifactId=Acronyms-UA-development -Dversion=0.1.0 -Dpackaging=jar

12. mvn install:install-file -Dfile=Keywords-UA-Development.jar -DgroupId=openbook-ua -DartifactId=Keywords-UA-development -Dversion=0.1.0 -Dpackaging=jar






