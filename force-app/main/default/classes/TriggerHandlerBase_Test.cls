@isTest
private class TriggerHandlerBase_Test {

  private static final String TRIGGER_CONTEXT_ERROR = 'Trigger handler called outside of Trigger execution';

  private static String lastMethodCalled;

  private static TriggerHandlerBase_Test.TestHandler handler;

  static {
    handler = new TriggerHandlerBase_Test.TestHandler();
    // override its internal trigger detection
    handler.isTriggerExecuting = true;
  }

  /***************************************
   * unit tests
   ***************************************/

  // contexts tests

  @isTest
  static void testBeforeInsert() {
    beforeInsertMode();
    handler.run();
    System.assertEquals('beforeInsert', lastMethodCalled, 'last method should be beforeInsert');
  }

  @isTest
  static void testBeforeUpdate() {
      Account a = TestRecordsFactory.createAccount();
          
        
    beforeUpdateMode();
    handler.addRecordstoBeforeUpdateMap(new Map<Id, sObject>{a.id => a});
    handler.addRecordstoAfterUpdateMap(new Map<Id, sObject>{a.id => a});
    handler.getOldBeforeUpdateMap(new Set<Id>{a.Id});
    handler.getOldAfterUpdateMap(new Set<Id>{a.Id});
    handler.run();
    System.assertEquals('beforeUpdate', lastMethodCalled, 'last method should be beforeUpdate');
  }

  @isTest
  static void testBeforeDelete() {
    beforeDeleteMode();
    handler.run();
    System.assertEquals('beforeDelete', lastMethodCalled, 'last method should be beforeDelete');
  }

  @isTest
  static void testAfterInsert() {
    afterInsertMode();
    handler.run();
    System.assertEquals('afterInsert', lastMethodCalled, 'last method should be afterInsert');
  }

  @isTest
  static void testAfterUpdate() {
    afterUpdateMode();
    handler.run();
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method should be afterUpdate');
  }

  @isTest
  static void testAfterDelete() {
    afterDeleteMode();
    handler.run();
    System.assertEquals('afterDelete', lastMethodCalled, 'last method should be afterDelete');
  }

  @isTest
  static void testAfterUndelete() {
    afterUndeleteMode();
    handler.run();
    System.assertEquals('afterUndelete', lastMethodCalled, 'last method should be afterUndelete');
  }

  @isTest 
  static void testNonTriggerContext() {
    try{
      handler.run();
      System.assert(false, 'the handler ran but should have thrown');
    } catch(TriggerHandlerBase.TriggerHandlerException te) {
      System.assertEquals(TRIGGER_CONTEXT_ERROR, te.getMessage(), 'the exception message should match');
    } catch(Exception e) {
      System.assert(false, 'the exception thrown was not expected: ' + e.getTypeName() + ': ' + e.getMessage());
    }
  }

  // test bypass api

  @isTest
  static void testBypassAPI() {
    afterUpdateMode();

    // test a bypass and run handler
    TriggerHandlerBase.bypass('TestHandler');
    handler.run();
    System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
    System.assertEquals(true, TriggerHandlerBase.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();

    // clear that bypass and run handler
    TriggerHandlerBase.clearBypass('TestHandler');
    handler.run();
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
    System.assertEquals(false, TriggerHandlerBase.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();

    // test a re-bypass and run handler
    TriggerHandlerBase.bypass('TestHandler');
    handler.run();
    System.assertEquals(null, lastMethodCalled, 'last method should be null when bypassed');
    System.assertEquals(true, TriggerHandlerBase.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();

    // clear all bypasses and run handler
    TriggerHandlerBase.clearAllBypasses();
    handler.run();
    System.assertEquals('afterUpdate', lastMethodCalled, 'last method called should be afterUpdate');
    System.assertEquals(false, TriggerHandlerBase.isBypassed('TestHandler'), 'test handler should be bypassed');
    resetTest();
  }

  // instance method tests

  /*@isTest
  static void testLoopCountClass() {
    TriggerHandlerBase.LoopCount lc = new TriggerHandlerBase.LoopCount();
    System.assertEquals(5, lc.getMax(), 'max should be five on init');
    System.assertEquals(0, lc.getCount(), 'count should be zero on init');

    lc.increment();
    System.assertEquals(1, lc.getCount(), 'count should be 1');
    System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 1');

    lc.increment();
    lc.increment();
    lc.increment();
    lc.increment();
    System.assertEquals(5, lc.getCount(), 'count should be 5');
    System.assertEquals(false, lc.exceeded(), 'should not be exceeded with count of 5');

    lc.increment();
    System.assertEquals(6, lc.getCount(), 'count should be 6');
    System.assertEquals(true, lc.exceeded(), 'should not be exceeded with count of 6');
  }*/

  // private method tests

  @isTest 
  static void testGetHandlerName() {
    System.assertEquals('TestHandler', handler.getHandlerName(), 'handler name should match class name');
  }

  // test virtual methods
  
  @isTest
  static void testVirtualMethods() {
    TriggerHandlerBase h = new TriggerHandlerBase();
    h.beforeInsert();
    h.beforeUpdate();
    h.beforeDelete();
    h.afterInsert();
    h.afterUpdate();
    h.afterDelete();
    System.assertEquals(null, lastMethodCalled);
    h.afterUndelete();
  }

  /***************************************
   * testing utilities
   ***************************************/

  private static void resetTest() {
    lastMethodCalled = null;
  }

  // modes for testing

  private static void beforeInsertMode() {
    handler.setTriggerContext('before insert', true);
  }

  private static void beforeUpdateMode() {
    handler.setTriggerContext('before update', true);
  }

  private static void beforeDeleteMode() {
    handler.setTriggerContext('before delete', true);
  }

  private static void afterInsertMode() {
    handler.setTriggerContext('after insert', true);
  }

  private static void afterUpdateMode() {
    handler.setTriggerContext('after update', true);
  }

  private static void afterDeleteMode() {
    handler.setTriggerContext('after delete', true);
  }

  private static void afterUndeleteMode() {
    handler.setTriggerContext('after undelete', true);
  }

  // test implementation of the TriggerHandlerBase

  private class TestHandler extends TriggerHandlerBase {

    public override void beforeInsert() {
      TriggerHandlerBase_Test.lastMethodCalled = 'beforeInsert';
    }

    public override void  beforeUpdate() {
      TriggerHandlerBase_Test.lastMethodCalled = 'beforeUpdate';
    }

    public override void beforeDelete() {
      TriggerHandlerBase_Test.lastMethodCalled = 'beforeDelete';
    }

    public override void afterInsert() {
      TriggerHandlerBase_Test.lastMethodCalled = 'afterInsert';
    }

    public override void afterUpdate() {
      TriggerHandlerBase_Test.lastMethodCalled = 'afterUpdate';
    }

    public override void afterDelete() {
      TriggerHandlerBase_Test.lastMethodCalled = 'afterDelete';
    }

    public override void afterUndelete() {
      TriggerHandlerBase_Test.lastMethodCalled = 'afterUndelete';
    }

  }
    
}