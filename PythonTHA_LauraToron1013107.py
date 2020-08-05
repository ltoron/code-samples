"""
Implicit Association Task
(Categories: Cat/dog, pleasant/unpleasant)

Python Take Home Assignment
Programming Skills: Python 2018-2019
Laura Toron
s1013107
July 2019
"""

from psychopy import core, visual, event, data, gui
55
""" functions """
# function to draw instructions
def drawInstruct(instructionfile):
    instructions.size = 1.2
    instructions.draw()
    win.flip()
    event.waitKeys()

# function to draw a message
def drawMsg(message):
    msg = visual.TextStim(win,message)
    msg.draw()
    win.flip()

# function to draw an image
def drawImg(img):
    img.size = 0.8
    img.draw()
    win.flip()

# function to draw an error message
def errorMsg():
    error_msg = visual.TextStim(win, 'X', color = 'red')
    error_msg.draw()
    win.flip()
    core.wait(2)




""" setting up the experiment """

#set up experiment screen and timer
win = visual.Window()
stim = visual.TextStim(win)
clock = core.Clock()
empty = 'n.a.'

#import conditions
imagefiles = data.importConditions('IATimages.xlsx')
words = data.importConditions('IATwords.xlsx')
imagexword = data.importConditions('IATwordscategories.xlsx')

#create trial handlers (could just have three, but I find this nicer)
trials_val = data.TrialHandler(words,1)
trials_name = data.TrialHandler(imagefiles,2)
trials_nameval = data.TrialHandler(imagexword,2)
trials_name2 = data.TrialHandler(imagefiles,2)
trials_nameval2 = data.TrialHandler(imagexword,2)

#congruency mapping normal versus inverse
keys_val = {'good':'f','bad':'j',999:'missing'}
keys_name = {'cat':'f','dog':'j',999:'missing'}
keys_nameinv = {'dog':'f','cat':'j',999:'missing'}

# create key reminders
rem_val = visual.TextStim(win, '{} = good, {} = bad'.format(keys_val['good'],keys_val['bad']), pos=(-0.7, 0.7))
rem_name = visual.TextStim(win, '{} = cat, {} = dog'.format(keys_name['cat'],keys_name['dog']), pos=(-0.7, -0.7))
rem_nameval = visual.TextStim(win, '{} = cat/good, {} = dog/bad'.format(keys_name['cat'],keys_name['dog']), pos=(0.4, 0.7))
rem_nameinv = visual.TextStim(win, '{} = dog, {} = cat'.format(keys_name['cat'],keys_name['dog']), pos=(-0.7, -0.7))
rem_namevalinv = visual.TextStim(win, '{} = dog/good, {} = cat/bad'.format(keys_nameinv['dog'],keys_nameinv['cat']), pos=(0.4, -0.7))




""" experiment """

# file with stats
padata = {'Subject number' : 999, 'Age' : 99, 'Gender' : ['n.a.','male', 'female', 'other']}
pdata = open('pdata.text', 'a')
myDlg = gui.DlgFromDict(dictionary = padata,title="Personal data")
if myDlg.OK:
    subject = padata['Subject number']
    pdata.write("{}\t{}\t{}\n".format(padata['Subject number'], padata['Age'], padata['Gender']))
else:
    print('user cancelled')
pdata.close()
win.fullscr = True



# give the general instructions
instructions = visual.ImageStim(win, 'instruct_general.png')
drawInstruct(instructions)

#block 1 (practice block with pos/neg words
block = 1
#draw instructions and reminder
instructions = visual.ImageStim(win, 'instruct_val.png')
drawInstruct(instructions)
rem_val.setAutoDraw(True)

#go through trials
for trial in trials_val:
    drawMsg(trial['wordstimuli'])
    clock.reset()
    respond = event.waitKeys(keyList=keys_val.values(), timeStamped=clock)
    response, latency = respond[0]
    
    # check correctness
    if response == keys_val[trial['valence']]:
        correct = True
    else:
        correct = False
    # draw an error message if incorrect
    if not correct:
        errorMsg()
    
    # save data
    outputFile = open('IATdata.txt', 'a')
    outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_val.thisN,empty,trial['wordstimuli'],trial['valence'],response,latency,correct)) 
    # not all these var.s were indicated to be saved, but I think I would want to save them
    outputFile.close()
rem_val.setAutoDraw(False)



# blocks 2-5
for i in range(2):
    # determine which block to start with depending on subject number
    if subject%2 == 0:
        inverse = True
    else:
        inverse = False
    
    
    
    
        #block 2/4 (practice block with pos/neg words)
        if (i == 0 & inverse == False) | (i == 1 & inverse == True):
            # draw instructions and reminder
            instructions = visual.ImageStim(win, 'instruct_2.png')
            drawInstruct(instructions)
            instructions = visual.ImageStim(win, 'instruct_name.png')
            drawInstruct(instructions)
            rem_name.setAutoDraw(True)
            keys_block = keys_name #set keys to inverse or not inverse
            block = 2
            #go through trials
            for trial in trials_name:
                image_file = visual.ImageStim(win, trial['imagefile'])
                drawImg(image_file)
                clock.reset()
                respond = event.waitKeys(keyList=keys_block.values(), timeStamped=clock)
                response, latency = respond[0]
                
                # check correctness
                if response == keys_block[trial['category']]:
                    correct = True
                else:
                    correct = False
                # draw an error message if incorrect
                if not correct:
                    errorMsg()
                
                # save data
                outputFile = open('IATdata.txt', 'a')
                outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_name.thisN,empty,trial['imagefile'],trial['category'],response,latency,correct)) 
                # not all these var.s were indicated to be saved, but I think I would want to save them
                outputFile.close()
        else:
            # draw instructions and reminder
            instructions = visual.ImageStim(win, 'instruct_4.png')
            drawInstruct(instructions)
            instructions = visual.ImageStim(win, 'instruct_nameinv.png')
            drawInstruct(instructions)
            rem_nameinv.setAutoDraw(True)
            keys_block = keys_nameinv #set keys to inverse or not inverse
            block = 4
            #go through trials
            for trial in trials_name2:
                image_file = visual.ImageStim(win, trial['imagefile'])
                drawImg(image_file)
                clock.reset()
                respond = event.waitKeys(keyList=keys_block.values(), timeStamped=clock)
                response, latency = respond[0]
                
                # check correctness
                if response == keys_block[trial['category']]:
                    correct = True
                else:
                    correct = False
                # draw an error message if incorrect
                if not correct:
                    errorMsg()
                
                # save data
                outputFile = open('IATdata.txt', 'a')
                outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_name2.thisN,empty,trial['imagefile'],trial['category'],response,latency,correct)) 
                # not all these var.s were indicated to be saved, but I think I would want to save them
                outputFile.close()
        
        rem_name.setAutoDraw(False)
        rem_nameinv.setAutoDraw(False)
        
        
        
        
        # block 3/5 (target block combining words and pictures)
        
        if (i == 0 & inverse == False) | (i == 1 & inverse == True):
            # draw instructions and reminder
            instructions = visual.ImageStim(win, 'instruct_nameval.png')
            drawInstruct(instructions)
            rem_nameval.setAutoDraw(True)
            keys_block = keys_name #set keys to inverse or not inverse
            block = 3
            
            #go through trials
            for trial in trials_nameval:
                if trial['type']=='image':
                    image_file = visual.ImageStim(win, trial['stimuli'])
                    drawImg(image_file)
                elif trial['type']=='word':
                    drawMsg(trial['stimuli'])
                clock.reset()
                
                respond = event.waitKeys(keyList=keys_block.values(), timeStamped=clock)
                response, latency = respond[0]
                
                # check correctness
                if (i == 0 & inverse == False) | (i == 1 & inverse == True):
                    if (response == keys_name[trial['category']]) | (response == keys_val[trial['valence']]):
                        correct = True
                    else:
                        correct = False
                else:
                    if (response == keys_nameinv[trial['category']]) | (response == keys_val[trial['valence']]):
                        correct = True
                    else:
                        correct = False
                
                # save data
                outputFile = open('IATdata.txt', 'a')
                if trial['type'] == 'image':
                    outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_nameval.thisN,trial['type'],trial['stimuli'],trial['category'],response,latency,correct))
                else:
                    outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_nameval.thisN,trial['type'],trial['stimuli'],trial['valence'],response,latency,correct))
                    
                # not all these var.s were indicated to be saved, but I think I would want to save them
                outputFile.close()
        else:
            # draw instructions and reminder
            instructions = visual.ImageStim(win, 'instruct_namevalinv.png')
            drawInstruct(instructions)
            rem_namevalinv.setAutoDraw(True)
            keys_block = keys_nameinv #set keys to inverse or not inverse
            block = 5
            #go through inverse trials
            for trial in trials_nameval2:
                if trial['type']=='image':
                    image_file = visual.ImageStim(win, trial['stimuli'])
                    drawImg(image_file)
                elif trial['type']=='word':
                    drawMsg(trial['stimuli'])
                clock.reset()
                
                respond = event.waitKeys(keyList=keys_block.values(), timeStamped=clock)
                response, latency = respond[0]
                
                # check correctness
                if (i == 0 & inverse == False) | (i == 1 & inverse == True):
                    if (response == keys_name[trial['category']]) | (response == keys_val[trial['valence']]):
                        correct = True
                    else:
                        correct = False
                else:
                    if (response == keys_nameinv[trial['category']]) | (response == keys_val[trial['valence']]):
                        correct = True
                    else:
                        correct = False
                
                # save data
                outputFile = open('IATdata.txt', 'a')
                if trial['type'] == 'image':
                    outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_nameval2.thisN,trial['type'],trial['stimuli'],trial['category'],response,latency,correct))
                else:
                    outputFile.write("{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{}\t,{:.3f}\t,{}\n".format(subject,block,trials_nameval2.thisN,trial['type'],trial['stimuli'],trial['valence'],response,latency,correct))
                # not all these var.s were indicated to be saved, but I think I would want to save them
                outputFile.close()
        
        rem_nameval.setAutoDraw(False)
        rem_namevalinv.setAutoDraw(False)

instructions = visual.ImageStim(win, 'instruct_end.png')
drawInstruct(instructions)
win.close()