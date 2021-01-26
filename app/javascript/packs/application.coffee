import ujs from '@rails/ujs'
import turbolinks from 'turbolinks'
import * as activestorage from '@rails/activestorage'

ujs.start()
turbolinks.start()
activestorage.start()

import 'channels'

import 'modules/bootstrap-native'
import 'modules/fontawesome'
