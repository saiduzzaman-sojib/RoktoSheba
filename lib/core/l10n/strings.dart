/// English text is the key; Bangla is the value. Missing keys fall back to English.
/// {name} placeholders are filled by trp().
const bnStrings = <String, String>{
  // Nav
  'Home': 'হোম',
  'Nearby': 'কাছে',
  'Request': 'অনুরোধ',
  'Camps': 'ক্যাম্প',
  'Profile': 'প্রোফাইল',

  // Common
  'Back': 'পিছনে',
  'Save': 'সংরক্ষণ',
  'Cancel': 'বাতিল',
  'Delete': 'মুছুন',
  'Yes': 'হ্যাঁ',
  'No': 'না',
  'Try again': 'আবার চেষ্টা করুন',
  'Cancel request': 'অনুরোধ বাতিল',
  'Log out': 'লগ আউট',
  'Log in': 'লগ ইন',
  'Language': 'ভাষা',
  'Appearance': 'থিম',
  'Auto': 'অটো',
  'Light': 'লাইট',
  'Dark': 'ডার্ক',
  'Edit details': 'তথ্য সম্পাদনা',
  'Change photo': 'ছবি পরিবর্তন',
  'Admin panel': 'অ্যাডমিন প্যানেল',
  'Terms & Privacy': 'শর্তাবলি ও গোপনীয়তা',
  'Delete my account': 'আমার অ্যাকাউন্ট মুছুন',
  'Please fill in every field.': 'সব ঘর পূরণ করুন।',
  'Could not save. Check your internet.': 'সংরক্ষণ করা যায়নি। ইন্টারনেট দেখুন।',

  // Splash / auth
  'Step forward.\nGive blood, give life.': 'এগিয়ে আসুন।\nরক্ত দিন, জীবন দিন।',
  'Find eligible donors near you in minutes, and keep your own donation record.':
      'কয়েক মিনিটেই আপনার কাছের যোগ্য রক্তদাতা খুঁজুন এবং নিজের রক্তদানের হিসাব রাখুন।',
  'Get started': 'শুরু করুন',
  'I already have an account': 'আমার অ্যাকাউন্ট আছে',
  'Welcome back': 'স্বাগতম',
  'Log in to find donors or accept requests.':
      'রক্তদাতা খুঁজতে বা অনুরোধ গ্রহণ করতে লগ ইন করুন।',
  'Mobile or email': 'মোবাইল বা ইমেইল',
  'Mobile number': 'মোবাইল নম্বর',
  'Password': 'পাসওয়ার্ড',
  'Forgot password?': 'পাসওয়ার্ড ভুলে গেছেন?',
  'New here? ': 'নতুন? ',
  'Register as a donor': 'রক্তদাতা হিসেবে নিবন্ধন করুন',
  'Continue as visitor': 'অতিথি হিসেবে চালিয়ে যান',
  'Join as a donor': 'রক্তদাতা হিসেবে যোগ দিন',
  'Add a photo so people can recognise you':
      'ছবি দিন যাতে মানুষ আপনাকে চিনতে পারে',
  'Full name': 'পুরো নাম',
  'Blood group': 'রক্তের গ্রুপ',
  'District': 'জেলা',
  'Area': 'এলাকা',
  'Last donation date (optional)': 'শেষ রক্তদানের তারিখ (ঐচ্ছিক)',
  'Create account': 'অ্যাকাউন্ট খুলুন',
  'Have an account? ': 'অ্যাকাউন্ট আছে? ',

  // Home
  'Good morning': 'শুভ সকাল',
  'Good afternoon': 'শুভ অপরাহ্ন',
  'Good evening': 'শুভ সন্ধ্যা',
  'Your status': 'আপনার অবস্থা',
  'Available to donate': 'রক্ত দিতে প্রস্তুত',
  'Not available': 'প্রস্তুত নই',
  'Nearby requests will alert you': 'কাছের অনুরোধ এলে আপনাকে জানানো হবে',
  'Hidden from donor search': 'দাতা তালিকা থেকে লুকানো',
  'Open the live map': 'লাইভ ম্যাপ খুলুন',
  'Map': 'ম্যাপ',
  'Find donor': 'দাতা খুঁজুন',
  'Live map & list': 'ম্যাপ ও তালিকা',
  'Request blood': 'রক্ত চান',
  'Notify matches': 'মিলে যাওয়াদের জানান',
  'Eligibility': 'যোগ্যতা',
  'Can I donate?': 'আমি কি দিতে পারি?',
  'Compatibility': 'সামঞ্জস্য',
  'Who gives to whom': 'কে কাকে দিতে পারে',
  'Urgent near you': 'আপনার কাছে জরুরি',
  'No open requests need your blood group right now.':
      'এখন আপনার রক্তের গ্রুপের কোনো খোলা অনুরোধ নেই।',
  'Find nearby hospitals': 'কাছের হাসপাতাল খুঁজুন',

  // Nearby
  'Donors near you': 'আপনার কাছের রক্তদাতা',
  'Within': 'ব্যাসার্ধ',
  'All': 'সব',

  // Request
  'New request': 'নতুন অনুরোধ',
  'My requests': 'আমার অনুরোধ',
  'For me': 'আমার জন্য',
  'Blood group needed': 'যে গ্রুপ লাগবে',
  'Hospital': 'হাসপাতাল',
  'Hospital name': 'হাসপাতালের নাম',
  'District and area': 'জেলা ও এলাকা',
  'Units needed': 'কত ব্যাগ লাগবে',
  'Urgency': 'জরুরি মাত্রা',
  'Critical': 'অতি জরুরি',
  'Within 24h': '২৪ ঘণ্টার মধ্যে',
  'Planned': 'পরিকল্পিত',
  'Post request & alert donors': 'অনুরোধ পোস্ট করুন ও দাতাদের জানান',
  'Accept & share my contact': 'গ্রহণ করুন ও আমার নম্বর দিন',
  'Not now': 'এখন না',
  'Mark as fulfilled': 'সম্পন্ন হিসেবে চিহ্নিত করুন',
  'Nearby matching donors are notified instantly.':
      'কাছের মিলে যাওয়া দাতাদের সঙ্গে সঙ্গে জানানো হয়।',

  // Request status
  'Cancel this request?': 'এই অনুরোধ বাতিল করবেন?',
  'Yes, cancel': 'হ্যাঁ, বাতিল করুন',
  '{n} unit · {urgency}': '{n} ব্যাগ · {urgency}',
  '{n} units · {urgency}': '{n} ব্যাগ · {urgency}',
  '{n} of {total} donors accepted': '{total} জনের মধ্যে {n} জন রাজি হয়েছেন',
  'Open': 'খোলা',
  'Fulfilled': 'সম্পন্ন',
  'Cancelled': 'বাতিল',
  'Waiting for the donor you asked.': 'আপনি যাকে অনুরোধ করেছেন তার উত্তরের অপেক্ষায়।',
  '{n} compatible donor nearby has been alerted.':
      'কাছের {n} জন সামঞ্জস্যপূর্ণ দাতাকে জানানো হয়েছে।',
  '{n} compatible donors nearby have been alerted.':
      'কাছের {n} জন সামঞ্জস্যপূর্ণ দাতাকে জানানো হয়েছে।',
  'This request is closed.': 'এই অনুরোধ বন্ধ হয়ে গেছে।',
  'Share on WhatsApp': 'হোয়াটসঅ্যাপে শেয়ার করুন',
  'WhatsApp': 'হোয়াটসঅ্যাপ',
  'Could not open WhatsApp.': 'হোয়াটসঅ্যাপ খোলা যায়নি।',
  'Waiting for donors to accept. Their contact appears here when they do.':
      'দাতাদের রাজি হওয়ার অপেক্ষায়। রাজি হলে তাদের যোগাযোগ এখানে দেখা যাবে।',
  'Could not load this request.': 'অনুরোধটি লোড করা যায়নি।',
  'This request no longer exists.': 'এই অনুরোধটি আর নেই।',
  'Requested by': 'অনুরোধকারী',
  'Distance': 'দূরত্ব',
  'Posted': 'পোস্ট করা হয়েছে',
  '{n} km away': '{n} কিমি দূরে',
  'You accepted this request. Thank you! 🎉':
      'আপনি এই অনুরোধ গ্রহণ করেছেন। ধন্যবাদ! 🎉',
  'Requester contact': 'অনুরোধকারীর যোগাযোগ',
  'Loading...': 'লোড হচ্ছে...',
  'Donation logged ✓': 'রক্তদান যোগ হয়েছে ✓',
  'I donated, log it': 'আমি রক্ত দিয়েছি, যোগ করুন',
  'This request was fulfilled.': 'এই অনুরোধ সম্পন্ন হয়েছে।',
  'This request was cancelled.': 'এই অনুরোধ বাতিল হয়েছে।',
  'You declined this request. You can still accept.':
      'আপনি এই অনুরোধ ফিরিয়ে দিয়েছেন। চাইলে এখনো গ্রহণ করতে পারেন।',
  'Your phone number is shared only if you accept, and only with this requester.':
      'আপনি রাজি হলেই কেবল এই অনুরোধকারীর সঙ্গে আপনার নম্বর শেয়ার হবে।',
  'Thank you! The requester was notified.': 'ধন্যবাদ! অনুরোধকারীকে জানানো হয়েছে।',
  'Request declined.': 'অনুরোধ ফিরিয়ে দেওয়া হয়েছে।',
  'Could not send. Check your internet.': 'পাঠানো যায়নি। ইন্টারনেট দেখুন।',
  'Donation logged. Thank you!': 'রক্তদান যোগ হয়েছে। ধন্যবাদ!',
  'Turn on availability on the Home screen first.':
      'আগে হোম স্ক্রিনে "প্রস্তুত" চালু করুন।',
  '{group} blood cannot be given to {need}.':
      '{group} রক্ত {need} গ্রুপকে দেওয়া যায় না।',
  'You can donate again from {date}.': 'আপনি {date} থেকে আবার রক্ত দিতে পারবেন।',

  // AI
  'AI insight': 'এআই বিশ্লেষণ',
  'AI insight: no matching donors found yet.':
      'এআই বিশ্লেষণ: এখনো মিলে যাওয়া কোনো দাতা পাওয়া যায়নি।',
  'About {n} of {total} matching donors are likely to respond.':
      'মিলে যাওয়া {total} জন দাতার মধ্যে প্রায় {n} জন সাড়া দিতে পারেন।',
  'Model: logistic regression trained on simulated data.':
      'মডেল: সিমুলেটেড ডেটায় ট্রেন করা লজিস্টিক রিগ্রেশন।',

  // Hospitals
  'Nearby Hospitals': 'কাছের হাসপাতাল',
  'Within 8 km of your location': 'আপনার অবস্থান থেকে ৮ কিমির মধ্যে',
  'Search hospital name': 'হাসপাতালের নাম খুঁজুন',
  'Could not load hospitals': 'হাসপাতাল লোড করা যায়নি',
  'No hospitals found': 'কোনো হাসপাতাল পাওয়া যায়নি',
  'Try a different name or move to a bigger area.':
      'অন্য নাম লিখুন বা বড় এলাকায় খুঁজুন।',
  'Call': 'কল',
  'Could not open': 'খোলা যায়নি',

  // Eligibility
  'Check eligibility': 'যোগ্যতা যাচাই করুন',
  'Answer a few quick questions.': 'কয়েকটি প্রশ্নের উত্তর দিন।',
  'Your age and weight': 'আপনার বয়স ও ওজন',
  'You can donate 🎉': 'আপনি রক্ত দিতে পারবেন 🎉',
  'Not yet eligible': 'এখনো যোগ্য নন',

  // Camps / blog
  'Donation camps': 'রক্তদান ক্যাম্প',
  'Upcoming': 'আসন্ন',
  'Near me': 'আমার কাছে',
  'Set reminder': 'রিমাইন্ডার দিন',
  'Reminder set ✓': 'রিমাইন্ডার দেওয়া হয়েছে ✓',
  'Directions': 'রুট',
  'Health tips & stories': 'স্বাস্থ্য পরামর্শ ও গল্প',
  'Read': 'পড়ুন',
  'Tips': 'পরামর্শ',
  'Myths': 'ভুল ধারণা',
  'Stories': 'গল্প',

  // Profile
  'Donor': 'রক্তদাতা',
  'Tap photo to change': 'ছবি বদলাতে ট্যাপ করুন',
  'Next eligible': 'পরবর্তী যোগ্যতা',
  'Now': 'এখনই',
  'Log a donation': 'রক্তদান যোগ করুন',
  'Donation history': 'রক্তদানের ইতিহাস',
  'No donations logged yet.': 'এখনো কোনো রক্তদান যোগ করা হয়নি।',
  'Blood donation': 'রক্তদান',
  'Completed': 'সম্পন্ন',
  'Requesters see your photo when you accept, so they can recognise you at the hospital.':
      'আপনি অনুরোধ গ্রহণ করলে অনুরোধকারী আপনার ছবি দেখবেন, যাতে হাসপাতালে আপনাকে চিনতে পারেন।',
  'Photo updated': 'ছবি আপডেট হয়েছে',
  'Could not update photo.': 'ছবি আপডেট করা যায়নি।',
  'When did you donate?': 'কবে রক্ত দিয়েছিলেন?',
  'Thank you! Eligible again on {date}.':
      'ধন্যবাদ! আপনি {date} তারিখ থেকে আবার যোগ্য।',
  'Donation saved.': 'রক্তদান সংরক্ষিত হয়েছে।',
  'Profile updated': 'প্রোফাইল আপডেট হয়েছে',
  'Delete your account?': 'আপনার অ্যাকাউন্ট মুছবেন?',
  'This removes your profile and phone number. It cannot be undone. Enter your password to confirm.':
      'এতে আপনার প্রোফাইল ও ফোন নম্বর মুছে যাবে। এটি ফেরানো যাবে না। নিশ্চিত করতে পাসওয়ার্ড দিন।',
  'Your account was deleted.': 'আপনার অ্যাকাউন্ট মুছে ফেলা হয়েছে।',

  // ---- Home ----
  'Your account is restricted by an admin.':
      'আপনার অ্যাকাউন্ট অ্যাডমিন সীমিত করেছেন।',
  'Your account is restricted by an admin, so you cannot post or answer requests.':
      'আপনার অ্যাকাউন্ট অ্যাডমিন সীমিত করেছেন, তাই আপনি অনুরোধ পোস্ট বা উত্তর দিতে পারবেন না।',
  'You are hidden from searches': 'আপনি এখন সার্চ থেকে লুকানো',
  'You are visible to nearby requests': 'আপনি এখন কাছের অনুরোধে দৃশ্যমান',
  'Could not update. Check your internet.':
      'আপডেট করা যায়নি। ইন্টারনেট দেখুন।',
  'Eligible again on {date}': '{date} তারিখ থেকে আবার যোগ্য',
  '{n} donors available now': '{n} জন রক্তদাতা এখন প্রস্তুত',

  // ---- Nearby ----
  'Location is off': 'লোকেশন বন্ধ আছে',
  'Turn on location services to find donors near you.':
      'কাছের রক্তদাতা খুঁজতে লোকেশন চালু করুন।',
  'Open location settings': 'লোকেশন সেটিংস খুলুন',
  'Location permission blocked': 'লোকেশনের অনুমতি বন্ধ',
  'Allow location for Roktosheba in your phone settings.':
      'ফোনের সেটিংসে রক্তসেবার জন্য লোকেশন চালু করুন।',
  'Open app settings': 'অ্যাপ সেটিংস খুলুন',
  'Location permission needed': 'লোকেশনের অনুমতি দরকার',
  'We need your location to show donors close to you.':
      'আপনার কাছের দাতা দেখাতে লোকেশন দরকার।',
  'Allow location': 'লোকেশন চালু করুন',
  'Could not get your location': 'আপনার লোকেশন পাওয়া যায়নি',
  'Check GPS and internet, then try again.':
      'জিপিএস ও ইন্টারনেট দেখে আবার চেষ্টা করুন।',
  '{n} km': '{n} কিমি',
  'Live · within {r}': 'লাইভ · {r} এর মধ্যে',
  'View': 'দেখুন',
  'Available': 'প্রস্তুত',
  'Verified ✓': 'যাচাইকৃত ✓',
  'No available donors in range yet. Try a bigger radius or another blood group.':
      'এই এলাকায় এখনো প্রস্তুত দাতা নেই। ব্যাসার্ধ বাড়ান বা অন্য গ্রুপ দেখুন।',
  '{n} donor · sorted by distance · tap one to see details':
      '{n} জন দাতা · দূরত্ব অনুযায়ী সাজানো · বিস্তারিত দেখতে ট্যাপ করুন',
  '{n} donors · sorted by distance · tap one to see details':
      '{n} জন দাতা · দূরত্ব অনুযায়ী সাজানো · বিস্তারিত দেখতে ট্যাপ করুন',

  // ---- Request form ----
  'Your account is restricted. You cannot post requests.':
      'আপনার অ্যাকাউন্ট সীমিত। আপনি অনুরোধ পোস্ট করতে পারবেন না।',
  'Enter the hospital and district.': 'হাসপাতাল ও জেলার নাম দিন।',
  'Could not post. Check your internet.':
      'পোস্ট করা যায়নি। ইন্টারনেট দেখুন।',
  'Direct request to {name}': '{name} কে সরাসরি অনুরোধ',
  'Only this donor will be notified.': 'শুধু এই দাতাকে জানানো হবে।',
  'Donors near your current location are alerted. For the best match, post from the hospital.':
      'আপনার বর্তমান অবস্থানের কাছের দাতাদের জানানো হয়। সবচেয়ে ভালো ফলের জন্য হাসপাতাল থেকে পোস্ট করুন।',
  'For me ({n})': 'আমার জন্য ({n})',
  'You are not available right now, so requests are hidden. Turn on availability from Home.':
      'আপনি এখন প্রস্তুত নন, তাই অনুরোধ লুকানো। হোম থেকে "প্রস্তুত" চালু করুন।',
  'No open requests match your blood group near you. You will get a banner when one arrives.':
      'আপনার কাছে আপনার গ্রুপের কোনো খোলা অনুরোধ নেই। নতুন এলে ব্যানারে জানানো হবে।',
  'You have not posted any requests yet.': 'আপনি এখনো কোনো অনুরোধ পোস্ট করেননি।',

  // ---- Request tiles / camps / time ----
  'Respond': 'সাড়া দিন',
  'Accepted ✓': 'গ্রহণ করেছেন ✓',
  'Declined': 'ফিরিয়ে দিয়েছেন',
  '{n} unit': '{n} ব্যাগ',
  '{n} units': '{n} ব্যাগ',
  'just now': 'এইমাত্র',
  '{n} min ago': '{n} মিনিট আগে',
  '{n} h ago': '{n} ঘণ্টা আগে',
  '{n} d ago': '{n} দিন আগে',
  'Camp today': 'আজ ক্যাম্প আছে',
  'Camp tomorrow': 'কাল ক্যাম্প আছে',

  // ---- Login / Register ----
  'Password reset by email only works for accounts created with an email.':
      'ইমেইল দিয়ে খোলা অ্যাকাউন্টেই কেবল ইমেইলে পাসওয়ার্ড রিসেট করা যায়।',
  'Password reset email sent.': 'পাসওয়ার্ড রিসেটের ইমেইল পাঠানো হয়েছে।',
  'Enter your mobile or email': 'মোবাইল বা ইমেইল দিন',
  'Enter a valid mobile number (01XXXXXXXXX)':
      'সঠিক মোবাইল নম্বর দিন (01XXXXXXXXX)',
  'Enter your password': 'পাসওয়ার্ড দিন',
  'Could not open photos. Check permission.':
      'ছবি খোলা যায়নি। অনুমতি দেখুন।',
  'Enter your area.': 'আপনার এলাকা লিখুন।',
  'Enter your full name': 'পুরো নাম লিখুন',
  'Mobile 01XXXXXXXXX': 'মোবাইল নম্বর 01XXXXXXXXX',
  'Required': 'আবশ্যক',
  'Last donation: {date}': 'শেষ রক্তদান: {date}',
  'Password (8+, letters and numbers)': 'পাসওয়ার্ড (৮+ অক্ষর, অক্ষর ও সংখ্যা)',
  'Use at least 8 characters': 'কমপক্ষে ৮ অক্ষর দিন',
  'Use letters and numbers': 'অক্ষর ও সংখ্যা দুটোই দিন',
  'Roktosheba': 'রক্তসেবা',

  // ---- Camps ----
  'Sample camps and articles added.': 'নমুনা ক্যাম্প ও লেখা যোগ হয়েছে।',
  'Could not load camps. Check your internet.':
      'ক্যাম্প লোড করা যায়নি। ইন্টারনেট দেখুন।',
  'No upcoming camps yet. Check back soon.':
      'এখনো কোনো আসন্ন ক্যাম্প নেই। কিছুদিন পর দেখুন।',
  'No upcoming camps yet.': 'এখনো কোনো আসন্ন ক্যাম্প নেই।',
  'Location needed': 'লোকেশন দরকার',
  'Allow location to sort camps by distance.':
      'দূরত্ব অনুযায়ী ক্যাম্প সাজাতে লোকেশন চালু করুন।',
  'Donation tips, myths and donor stories':
      'রক্তদানের পরামর্শ, ভুল ধারণা ও দাতাদের গল্প',
  'Reminder set. We will remind you on Home when it is close.':
      'রিমাইন্ডার দেওয়া হয়েছে। সময় কাছে এলে হোমে জানানো হবে।',
  'Reminder removed': 'রিমাইন্ডার সরানো হয়েছে',

  // ---- Eligibility ----
  'Enter your age and weight.': 'বয়স ও ওজন লিখুন।',
  'Age e.g. 25': 'বয়স যেমন ২৫',
  'Kg e.g. 58': 'কেজি যেমন ৫৮',
  'Last donation date (tap to set)': 'শেষ রক্তদানের তারিখ (ট্যাপ করুন)',
  'Fever, cold or infection now?': 'এখন জ্বর, সর্দি বা সংক্রমণ আছে?',
  'Chronic condition?': 'দীর্ঘমেয়াদী রোগ আছে?',
  'Turn on availability so nearby requests can reach you.':
      '"প্রস্তুত" চালু করুন, যাতে কাছের অনুরোধ আপনার কাছে পৌঁছায়।',

  // ---- Compatibility ----
  'Blood compatibility': 'রক্তের সামঞ্জস্য',
  'Who each group can give to, and receive from.':
      'কোন গ্রুপ কাকে দিতে ও কার কাছ থেকে নিতে পারে।',
  'All groups': 'সব গ্রুপ',
  'Gives to: {list}': 'দিতে পারে: {list}',
  'Receives from: {list}': 'নিতে পারে: {list}',
  'O- is the universal donor. AB+ is the universal recipient.':
      'O- সবাইকে দিতে পারে। AB+ সবার কাছ থেকে নিতে পারে।',

  // ---- Donor detail ----
  'Back to map': 'ম্যাপে ফিরুন',
  'Could not load this donor.': 'এই দাতার তথ্য লোড করা যায়নি।',
  'This donor no longer exists.': 'এই দাতা আর নেই।',
  'Eligible and available': 'যোগ্য ও প্রস্তুত',
  'Busy right now': 'এখন ব্যস্ত',
  '✓ Verified donor': '✓ যাচাইকৃত দাতা',
  'Last donation': 'শেষ রক্তদান',
  'Not shared': 'জানানো হয়নি',
  'Contact number': 'যোগাযোগ নম্বর',
  'Shared after donor accepts': 'দাতা রাজি হলে জানানো হবে',
  'Phone numbers stay private. The donor gets an alert and decides whether to accept.':
      'ফোন নম্বর গোপন থাকে। দাতা অ্যালার্ট পান এবং রাজি হবেন কি না নিজে ঠিক করেন।',
  'Send request to donor': 'দাতাকে অনুরোধ পাঠান',

  // ---- Hospitals ----
  'Location is turned off. Please turn on GPS.':
      'লোকেশন বন্ধ আছে। জিপিএস চালু করুন।',
  'Location permission is needed to find hospitals near you.':
      'কাছের হাসপাতাল খুঁজতে লোকেশনের অনুমতি দরকার।',
  'Hospital server busy. Try again in a moment.':
      'হাসপাতালের সার্ভার ব্যস্ত। একটু পর আবার চেষ্টা করুন।',


  // ---- Auth errors ----
  'Wrong mobile/email or password.': 'মোবাইল/ইমেইল বা পাসওয়ার্ড ভুল।',
  'This mobile number is already registered. Please log in.':
      'এই মোবাইল নম্বর আগেই নিবন্ধিত। অনুগ্রহ করে লগ ইন করুন।',
  'Password is too weak. Use at least 8 characters with letters and numbers.':
      'পাসওয়ার্ড দুর্বল। কমপক্ষে ৮ অক্ষর, অক্ষর ও সংখ্যা দিন।',
  'Please log in again, then try once more.':
      'আবার লগ ইন করে নতুন করে চেষ্টা করুন।',
  'No internet connection. Please try again.':
      'ইন্টারনেট সংযোগ নেই। আবার চেষ্টা করুন।',
  'Too many attempts. Please wait a minute and try again.':
      'অনেকবার চেষ্টা হয়েছে। এক মিনিট পর আবার চেষ্টা করুন।',
  'Email/Password sign-in is not enabled in Firebase console.':
      'Firebase-এ ইমেইল/পাসওয়ার্ড লগ ইন চালু নেই।',
  'Login problem ({code}).': 'লগ ইনে সমস্যা ({code})।',
  'Could not save your profile (permission denied). Check Firestore rules.':
      'প্রোফাইল সেভ করা যায়নি (অনুমতি নেই)। Firestore rules দেখুন।',
  'Something went wrong. Please try again.':
      'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।',

  // ---- Eligibility reasons ----
  'Donors must be {min} to {max} years old.':
      'দাতার বয়স {min} থেকে {max} বছরের মধ্যে হতে হবে।',
  'Minimum weight is {kg} kg.': 'সর্বনিম্ন ওজন {kg} কেজি।',
  'Wait until {date} ({days} days after your last donation).':
      '{date} পর্যন্ত অপেক্ষা করুন (শেষ রক্তদানের {days} দিন পর)।',
  'Wait until you have fully recovered.': 'পুরোপুরি সুস্থ হওয়া পর্যন্ত অপেক্ষা করুন।',
  'Please ask a doctor before donating.': 'রক্ত দেওয়ার আগে ডাক্তারের পরামর্শ নিন।',

  // ---- Alert banner ----
  'Urgent: {group} blood needed': 'জরুরি: {group} রক্ত দরকার',
  '{n} km from you': 'আপনার থেকে {n} কিমি',
  'now': 'এখন',

  // ---- Terms ----
  'What Roktosheba is': 'রক্তসেবা কী',
  'Roktosheba helps people find voluntary blood donors nearby. We do not collect, store or supply blood.':
      'রক্তসেবা কাছের স্বেচ্ছাসেবী রক্তদাতা খুঁজে পেতে সাহায্য করে। আমরা রক্ত সংগ্রহ, সংরক্ষণ বা সরবরাহ করি না।',
  'Who can use it': 'কারা ব্যবহার করতে পারবেন',
  'You must be 18 or older. Donate only if you are healthy and meet the donation rules. The final decision is always made by the hospital or blood bank, not this app.':
      'বয়স ১৮ বা তার বেশি হতে হবে। সুস্থ থাকলে এবং রক্তদানের নিয়ম মানলেই কেবল রক্ত দিন। চূড়ান্ত সিদ্ধান্ত সবসময় হাসপাতাল বা ব্লাড ব্যাংকের, এই অ্যাপের নয়।',
  'Not medical advice': 'এটি চিকিৎসা পরামর্শ নয়',
  'The app gives general information only. It does not replace a doctor. In an emergency, call 999 or go to the nearest hospital.':
      'অ্যাপে শুধু সাধারণ তথ্য দেওয়া হয়। এটি ডাক্তারের বিকল্প নয়। জরুরি অবস্থায় ৯৯৯-এ কল করুন বা কাছের হাসপাতালে যান।',
  'Blood donation is free': 'রক্তদান বিনামূল্যে',
  'Donating and requesting blood here is voluntary. Never ask for or offer money for blood.':
      'এখানে রক্ত দেওয়া ও চাওয়া স্বেচ্ছায়। রক্তের জন্য কখনো টাকা চাইবেন না বা দেবেন না।',
  'What we collect': 'আমরা যা সংগ্রহ করি',
  'Your name, blood group, area, approximate location (rounded to about 100 m), mobile number, photo and donation dates.':
      'আপনার নাম, রক্তের গ্রুপ, এলাকা, আনুমানিক লোকেশন (প্রায় ১০০ মিটারে গোল করা), মোবাইল নম্বর, ছবি ও রক্তদানের তারিখ।',
  'Who sees it': 'কে দেখতে পায়',
  'Signed-in users can see your name, photo, blood group, area and availability. Your mobile number is shared only with the person you choose to help, and only after you accept their request. We do not sell your data.':
      'লগ ইন করা ব্যবহারকারীরা আপনার নাম, ছবি, রক্তের গ্রুপ, এলাকা ও প্রস্তুত থাকার অবস্থা দেখতে পায়। আপনার মোবাইল নম্বর শুধু সেই ব্যক্তিকে জানানো হয় যাকে আপনি সাহায্য করবেন, এবং তাঁর অনুরোধ রাজি হওয়ার পরেই। আমরা আপনার তথ্য বিক্রি করি না।',
  'Your responsibilities': 'আপনার দায়িত্ব',
  'Give true information. Do not post fake or spam requests. Do not harass anyone or misuse another person\'s contact details.':
      'সঠিক তথ্য দিন। ভুয়া বা স্প্যাম অনুরোধ দেবেন না। কাউকে বিরক্ত করবেন না বা অন্যের যোগাযোগের তথ্য অপব্যবহার করবেন না।',
  'Restrictions': 'নিষেধাজ্ঞা',
  'Admins can restrict or remove accounts that misuse the app.':
      'অ্যাপ অপব্যবহার করলে অ্যাডমিন অ্যাকাউন্ট সীমিত বা মুছে দিতে পারেন।',
  'Your control': 'আপনার নিয়ন্ত্রণ',
  'You can turn availability off, edit your details, or delete your account from Profile at any time. Deleting removes your profile and phone number.':
      'আপনি যেকোনো সময় প্রোফাইল থেকে প্রস্তুত থাকা বন্ধ, তথ্য বদল বা অ্যাকাউন্ট মুছতে পারেন। মুছলে আপনার প্রোফাইল ও ফোন নম্বর সরে যায়।',
  'Changes': 'পরিবর্তন',
  'If these terms change, we will ask you to agree again.':
      'শর্ত বদলালে আমরা আবার আপনার সম্মতি চাইব।',


  // ---- Onboarding ----
  'Skip': 'এড়িয়ে যান',
  'Next': 'পরের',
  'Find blood fast': 'দ্রুত রক্ত খুঁজুন',
  'Search eligible donors near you by blood group and distance, in minutes.':
      'রক্তের গ্রুপ ও দূরত্ব অনুযায়ী কাছের যোগ্য দাতা মিনিটের মধ্যে খুঁজে নিন।',
  'Your phone stays private': 'আপনার ফোন নম্বর গোপন থাকে',
  'Your number is shared only if you accept a request, and only with that requester.':
      'আপনি অনুরোধ রাজি হলে তবেই নম্বর জানানো হয়, এবং শুধু সেই অনুরোধকারীকে।',
  'Be a lifesaver': 'জীবন বাঁচান',
  'Turn on availability, get alerts for nearby requests, and track your donation record.':
      '"প্রস্তুত" চালু করুন, কাছের অনুরোধের অ্যালার্ট পান এবং নিজের রক্তদানের রেকর্ড রাখুন।',
};