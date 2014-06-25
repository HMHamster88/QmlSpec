
import QtQuick 2.1

import QmlSpec 1.0


Item {
  id: root
  
  property var name: String(root)
  
  property var testComponents
  
  property var testReporter: TestReporterConsole { }
  
  
  signal finished()
  
  function run() {
    try {
      testReporter.suiteBegin({ name: root.name })
      
      for(var i in testComponents) {
        var testComponent = testComponents[i]
        var testObjectParent = root
        
        var createTestObject
        createTestObject = function() {
          if (testComponent.status == Component.Ready) {
            return testComponent.createObject(testObjectParent, {})
          } 
          else if (testComponent.status == Component.Loading) {
            testComponent.statusChanged.connect(createTestObject)
          } 
          else if (testComponent.status == Component.Error) {
            console.log("Error loading testComponent:",
                        testComponent.errorString())
          }
        }
        
        createTestObject()
        
        for(var j = TestGroupRegistry.testGroups.length - 1; j >= 0; j--) {
          var testGroup = TestGroupRegistry.testGroups[j]
          testGroup.testReporter = testReporter
          testGroup._run()
        }
        TestGroupRegistry.clear()
      }
      
      testReporter.suiteEnd({ name: root.name })
    }
    catch(exc) {
      console.error("ERROR in TestSuite#run: %1\n%2".arg(exc).arg(exc.stack))
      quit()
    }
    
    finished()
  }
  
  function quit() {
    quitTimer.start()
  }
  
  // This is an ugly hack, here because
  // Qt.quit() does not work if called too soon after creation.
  // This timer will keep trying to quit every millisecond...
  Timer {
    id: quitTimer
    interval: 1
    repeat: true
    onTriggered: Qt.quit()
  }
}
