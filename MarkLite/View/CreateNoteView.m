//
//  CreateNoteView.m
//  MarkLite
//
//  Created by zhubch on 11/30/15.
//  Copyright © 2015 zhubch. All rights reserved.
//

#import "CreateNoteView.h"
#import "FileItemCell.h"
#import "FileManager.h"

static CGFloat w;
static CGFloat h;

@implementation CreateNoteView
{
    NSMutableArray *dataArray;
    UIControl *control;
    Item *selecteItem;
}

- (void)show
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;

    _isShow = YES;
    if (control == nil) {
        control = [[UIControl alloc]initWithFrame:window.bounds];
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        [control addTarget:self action:@selector(remove) forControlEvents:UIControlEventTouchDown];
        [control addSubview:self];
        
        self.layer.shadowOffset = CGSizeMake(5, 5);
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowColor = [UIColor grayColor].CGColor;
        self.layer.shadowRadius = 5;
        self.layer.cornerRadius = 5;
    }
    
    [window addSubview:control];
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
        self.center = control.center;
    } completion:^(BOOL finished) {
        //
    }];
}

- (void)remove
{
    _isShow = NO;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        control.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
        self.frame = CGRectMake(w * 0.05, kScreenHeight, w, h);
    } completion:^(BOOL finished) {
        if (finished) {
            [control removeFromSuperview];
        }
    }];
}

- (void)reset
{
    UIWindow *window=[UIApplication sharedApplication].keyWindow;

    control.frame = window.bounds;

    self.frame = CGRectMake(w * 0.05, kScreenHeight, w, h);
}

+ (instancetype)instance
{
    CreateNoteView *view = [[NSBundle mainBundle]loadNibNamed:@"CreateNoteView" owner:self options:nil].firstObject;
    w = MIN(kScreenWidth, kScreenHeight) * 0.9;
    h = kDevicePhone ? w * 1.4 : w;
    view.frame = CGRectMake(w * 0.05, kScreenHeight, w, h);

    [view.folderListView registerNib:[UINib nibWithNibName:@"FileItemCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"fileItemCell"];
    return view;
}

- (void)setRoot:(Item *)root
{
    NSPredicate *pre = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        Item *i = evaluatedObject;
        if (i.type == FileTypeFolder) {
            return YES;
        }
        return NO;
    }];
    dataArray = [root.items filteredArrayUsingPredicate:pre].mutableCopy;
    [dataArray insertObject:root atIndex:0];
    [self.folderListView reloadData];
}

- (IBAction)create:(id)sender {
    if (_nameText.text.length==0) {
        showToast(@"请输入标题");
        return;
    }
    if ([_nameText.text containsString:@"."] | [_nameText.text containsString:@"/"] | [_nameText.text containsString:@"*"]) {
        showToast(@"请不要输入'./*'等特殊字符");
        return ;
    }
    if (selecteItem == nil) {
        showToast(@"请选择父目录");
        return ;
    }
    [self remove];
    NSString *name = _nameText.text;
    NSString *path = [[selecteItem.path stringByAppendingPathComponent:name] stringByAppendingPathExtension:@"md"];
    Item *i = [[Item alloc]init];
    i.path = path;
    i.open = YES;
    [[FileManager sharedManager] createFile:path Content:[NSData data]];
    
    [selecteItem addChild:i];
    
    self.didCreateNote(i);
}

#pragma mark UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FileItemCell *cell = (FileItemCell*)[tableView dequeueReusableCellWithIdentifier:@"fileItemCell" forIndexPath:indexPath];
    Item *item = dataArray[indexPath.row];
    cell.shift = 1;
    cell.item = item;
    cell.addBtn.hidden = YES;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    selecteItem = dataArray[indexPath.row];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
