#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

/**
 * Definition for singly-linked list.
 */

struct ListNode {
        int val;
        struct ListNode *next;
};

struct ListNode head;
 static uint32_t flag = 0;
 static uint32_t carry = 0;

 int get_list_value(struct ListNode** ll)
 {
     int rv;

     rv = 0;
     if (*ll != NULL)
     {
         rv = (*ll)->val;
         *ll = (*ll)->next;
     }
     return rv;
 }
struct ListNode* addTwoNumbers(struct ListNode* l1, struct ListNode* l2)
{
    struct ListNode *entry;

    if ((l1 == NULL) || (l2 == NULL))
    {
        return NULL;
    }
    entry = (struct ListNode *) malloc(sizeof(struct ListNode));
    if (entry == NULL)
    {
        return NULL;
    }
    if (flag == 0)
    {
        head.next = entry;
    }

    while ((l1 != NULL) && (l2 != NULL))
    {
        entry->val = get_list_value(&l1) + get_list_value(&l2) + carry;
        carry = entry->val - entry->val % 10;
        entry->val = entry->val - carry;
        carry /= 10;
        entry = entry->next;
        entry = (struct ListNode *) malloc(sizeof(struct ListNode));
    }

    return head.next;
}

int main(int argc, char *argv[])
{
        addTwoNumbers();
}

