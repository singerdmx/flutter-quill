const quillTextSample = [
  {'insert': 'Flutter Quill'},
  {
    'attributes': {'header': 1},
    'insert': '\n'
  },
  {'insert': '\nRich text editor for Flutter'},
  {
    'attributes': {'header': 2},
    'insert': '\n'
  },
  {'insert': 'Quill component for Flutter'},
  {
    'attributes': {'color': 'rgba(0, 0, 0, 0.847)'},
    'insert': ' and '
  },
  {
    'attributes': {'link': 'https://bulletjournal.us/home/index.html'},
    'insert': 'Bullet Journal'
  },
  {
    'insert':
        ':\nTrack personal and group journals (ToDo, Note, Ledger) from multiple views with timely reminders'
  },
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n'
  },
  {
    'insert':
        'Share your tasks and notes with teammates, and see changes as they happen in real-time, across all devices'
  },
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'Check out what you and your teammates are working on each day'},
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': '\nSplitting bills with friends can never be easier.'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'Start creating a group and invite your friends to join.'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'Create a BuJo of Ledger type to see expense or balance summary.'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n'
  },
  {
    'insert':
        '\nAttach one or multiple labels to tasks, notes or transactions. Later you can track them just using the label(s).'
  },
  {
    'attributes': {'blockquote': true},
    'insert': '\n'
  },
  {'insert': "\nvar BuJo = 'Bullet' + 'Journal'"},
  {
    'attributes': {'code-block': true},
    'insert': '\n'
  },
  {'insert': '\nStart tracking in your browser'},
  {
    'attributes': {'indent': 1},
    'insert': '\n'
  },
  {'insert': 'Stop the timer on your phone'},
  {
    'attributes': {'indent': 1},
    'insert': '\n'
  },
  {'insert': 'All your time entries are synced'},
  {
    'attributes': {'indent': 2},
    'insert': '\n'
  },
  {'insert': 'between the phone apps'},
  {
    'attributes': {'indent': 2},
    'insert': '\n'
  },
  {'insert': 'and the website.'},
  {
    'attributes': {'indent': 3},
    'insert': '\n'
  },
  {'insert': '\n'},
  {'insert': '\nCenter Align'},
  {
    'attributes': {'align': 'center'},
    'insert': '\n'
  },
  {'insert': 'Right Align'},
  {
    'attributes': {'align': 'right'},
    'insert': '\n'
  },
  {'insert': 'Justify Align'},
  {
    'attributes': {'align': 'justify'},
    'insert': '\n'
  },
  {'insert': 'Have trouble finding things? '},
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'Just type in the search bar'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'and easily find contents'},
  {
    'attributes': {'indent': 2, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'across projects or folders.'},
  {
    'attributes': {'indent': 2, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'It matches text in your note or task.'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'Enable reminders so that you will get notified by'},
  {
    'attributes': {'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'email'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'message on your phone'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'popup on the web site'},
  {
    'attributes': {'indent': 1, 'list': 'ordered'},
    'insert': '\n'
  },
  {'insert': 'Create a BuJo serving as project or folder'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'Organize your'},
  {
    'attributes': {'indent': 1, 'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'tasks'},
  {
    'attributes': {'indent': 2, 'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'notes'},
  {
    'attributes': {'indent': 2, 'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'transactions'},
  {
    'attributes': {'indent': 2, 'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'under BuJo '},
  {
    'attributes': {'indent': 3, 'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'See them in Calendar'},
  {
    'attributes': {'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'or hierarchical view'},
  {
    'attributes': {'indent': 1, 'list': 'bullet'},
    'insert': '\n'
  },
  {'insert': 'this is a check list'},
  {
    'attributes': {'list': 'checked'},
    'insert': '\n'
  },
  {'insert': 'this is a uncheck list'},
  {
    'attributes': {'list': 'unchecked'},
    'insert': '\n'
  },
  {'insert': 'Font '},
  {
    'attributes': {'font': 'sans-serif'},
    'insert': 'Sans Serif'
  },
  {'insert': ' '},
  {
    'attributes': {'font': 'serif'},
    'insert': 'Serif'
  },
  {'insert': ' '},
  {
    'attributes': {'font': 'monospace'},
    'insert': 'Monospace'
  },
  {'insert': ' Size '},
  {
    'attributes': {'size': 'small'},
    'insert': 'Small'
  },
  {'insert': ' '},
  {
    'attributes': {'size': 'large'},
    'insert': 'Large'
  },
  {'insert': ' '},
  {
    'attributes': {'size': 'huge'},
    'insert': 'Huge'
  },
  {
    'attributes': {'size': '15.0'},
    'insert': 'font size 15'
  },
  {'insert': ' '},
  {
    'attributes': {'size': '35'},
    'insert': 'font size 35'
  },
  {'insert': ' '},
  {
    'attributes': {'size': '20'},
    'insert': 'font size 20'
  },
  {
    'attributes': {'token': 'built_in'},
    'insert': ' diff'
  },
  {
    'attributes': {'token': 'operator'},
    'insert': '-match'
  },
  {
    'attributes': {'token': 'literal'},
    'insert': '-patch'
  },
  {
    'insert': {
      'image':
          'https://user-images.githubusercontent.com/122956/72955931-ccc07900-3d52-11ea-89b1-d468a6e2aa2b.png'
    },
    'attributes': {'width': '230', 'style': 'display: block; margin: auto;'}
  },
  {'insert': '\n'}
];
