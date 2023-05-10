// ===========================================================================
// Object: NoteLogger
// Company: Cloudware Connections, Inc.
// Author: Reid Beckett
// Purpose: Implementation of NoteLogger
// ===========================================================================
// Changes: 2016-04-29 Reid Beckett
//           Class created
// ===========================================================================
global class NoteLogger 
{
    private static Map<Id, Map<String,Note>> notesMap;

    public static void log(Id parentId, String title, String message) 
    {
        if(notesMap == null) notesMap = new Map<Id,Map<String,Note>>();
        //Note n = new Note(ParentId = parentId, Body=message, Title = title);
        Map<String,Note> notesByTitle = null;
        if(notesMap.containsKey(parentId)) {
            notesByTitle = notesMap.get(parentId);
            if(notesByTitle.containsKey(title)) {
                String b = notesByTitle.get(title).Body;
                b += '\r\n' + message;
                if(b.length() <= Note.fields.Body.getDescribe().getLength())
                    notesByTitle.put(title, createNote(parentId, title, b));
            }else{
                notesByTitle.put(title, createNote(parentId, title, message));
            }
        } else {
            notesByTitle = new Map<String,Note>{
                title => createNote(parentId, title, message)
            };
            notesMap.put(parentId, notesByTitle);
        }
    }

    public static void flush()
    {
        List<Note> inserts = new List<Note>();
        for(Map<String,Note> notesByTitle : notesMap.values()) 
        {
            inserts.addAll(notesByTitle.values());
        }
        if(!Test.isRunningTest()) insert inserts;
    }

    private static Note createNote(Id parentId, String title, String body) {
        if(body != null && body.length() > Note.fields.Body.getDescribe().getLength()) {
            body = body.substring(0, Note.fields.Body.getDescribe().getLength());
        }
        return new Note(ParentId = parentId, Body=body, Title = title);
    }
}